# Methods using the structures defined in `structs.jl`

using TOML
using Crayons.Box
using Formatting


# Merge all the results into one
function merge(results::Vector{Result})::Result
    combined = Result()
    combined.total_placements = sum([r.total_placements for r in results])
    combined.successful_placements = sum([r.successful_placements for r in results])
    combined.dead_ends = sum([r.dead_ends for r in results])
    combined.best_times = sum([r.best_times for r in results])
    combined.solutions = vcat([r.solutions for r in results]...)
    return combined
end

# If a given problem is consistent might have a solution
function consistent(prob::Problem)::Bool
    boardgaps = prod(size(prob.board.shape)) - (sum(prob.board.shape)÷13)
    piecegaps = sum([sum(ifelse.(p.shape .!= 0, 1, 0)) for p in prob.pieces])
    return boardgaps == piecegaps
end

# Load a problem from disk
function loadproblem(fname::AbstractString)::Problem
    desc = TOML.parse(read(fname, String))

    if (!haskey(desc, "board")) || (!haskey(desc, "pieces"))
        return throw(ArgumentError("Missing board or piece description"))
    end

    board = newboard(desc["board"])
    pieces = [newpiece(map, i) for (i, map) in enumerate(desc["pieces"])]

    # check that empty space of the board corresponds to the size of the pieces
    prob = Problem(pieces, board)
    if !consistent(prob)
        @warn "Problem is inconsistent. The number of gaps in the board ($(prod(size(prob.board.shape)) - (sum(prob.board.shape)÷13))) is different to the total size of all pieces ($(sum([sum(ifelse.(p.shape .!= 0, 1, 0)) for p in prob.pieces])))."
    end
    return prob
end

# Whats in the potato now?
function eat!(potato::Potato, b::Board, res::Result, remaining::Vector)
    if time() > potato.dt + potato.lasttime  # update
        if potato.threaded
            lock(potato.reentractlocker) do
                potato.glo_total += res.total_placements
                potato.glo_successfull += res.successful_placements
                potato.glo_dead_ends += res.dead_ends
                potato.lasttime = time()

                # Avoid double counting
                res.total_placements = 0
                res.successful_placements = 0
                res.dead_ends = 0

                potato.func(b, potato, remaining)
            end
        else
            potato.func(b, res, remaining)
        end
    end
end

# A worker finished a problem!
function finished(potato::Potato, i::Int, result::Result)
    lock(potato.reentractlocker) do
        potato.onfinish(potato, i, result)
    end
end

# Default callback
function defaultpotato()::Potato
    # Threadsafe 

    function ticker(b::Board, potato::Potato, remain)
        clear_lines(1)
        println("(Thread $(threadid())) Placement successrate of $(format(potato.glo_successfull, commas=true))/$(format(potato.glo_total, commas=true)) = ",
            BOLD(string(round(potato.glo_successfull/potato.glo_total*100, digits=2)) * "%"), " of $(potato.glo_numsols) solutions. \t[",
            string(round((now()-potato.tic).value/1000, digits=2)), " total seconds]")
    end 

    function finished(potato::Potato, i::Int, result::Result)
        clear_lines(1)
        potato.glo_numsols += length(result.solutions)
        if length(result.solutions) > 1
            print("    ", GREEN_FG("▶ "))
        else
            print("    ", RED_FG("▶ "))
        end
        println("Worker ", BOLD(string(threadid())), " finished subproblem #$i finding $(length(result.solutions)) solutions in ", ITALICS("$(result.duration/1000)"),  " seconds.\n")
    end
    return Potato(func=ticker, onfinish=finished, threaded=true)
end


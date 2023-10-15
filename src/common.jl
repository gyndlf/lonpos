# Methods using the structures defined in `structs.jl`

using TOML

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

# Process the :from the potato
function advance!(potato::Potato, from::Symbol, vars)
    if time() > potato.dt + potato.lasttime  # update
        lock(potato.reentractlocker) do
            potato.lasttime = time()
            if from == :ifbest
                potato.ifbest(vars...)
            elseif from == :ifsolution
                potato.ifsolution(vars...)
            else
                @error "Unknown symbol!" from
            end
        end
    end
end

# Default callback
function defaultpotato()::Potato
    # Threadsafe default
    return Potato()
end


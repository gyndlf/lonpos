# d7320 (init)
# d7844 (julia)
# Algorithm core


# convention
# 0 = empty space
# -1 = outside
# char = filled space of piece corresponding to the char

using Dates  # for now()
using Base.Threads


function rotate(piece::Piece)::Piece
    """Rotate a piece 90 degrees clockwise""" 
    return newpiece(rotr90(piece.shape))
end


function flip(piece::Piece)::Piece
    """Flip a piece 180 degrees"""
    return newpiece(reverse(piece.shape, dims=2))  # flip along the vertical line of symmetry
end


function is_in(l::Vector{Piece}, b::Piece)::Bool
    dup = false
    for pp in l 
        if b == pp
            dup = true
            break
        end
    end
    return dup
end


function save_solutions(sols::Vector, path::String)
    """Save the solutions to disk"""
    # convert from list to ndarray then save
    println("Saving to $path")
    throw("unimplemented")
    #np.save(path, sols)
end


function load_solutions(path::String)
    """Load a solution from disk"""
    throw("unimplemented")
    #return np.load(path)
end

function create_permutations(pieces::Vector{Piece{T}})::Vector{Vector{Piece{T}}} where {T<:Integer}
    """Create all the possible permutations (rotations and flips) of all given pieces.
    A list of a list of different ways"""
    all_perms = Vector{Piece}[]

    for p in pieces
        perms = Piece[]
        for f in 1:2
            for r in 1:4
                if !is_in(perms, p)
                    push!(perms, p)
                end
                p = rotate(p)
            end
            p = flip(p)
        end
        push!(all_perms, perms)
    end
    return all_perms
end

function place(board::Board, piece::Piece, x::Integer, y::Integer)::Tuple{Bool, Board}
    """Place the piece in the board if possible"""
    # Offset the piece if it is L or +
    offset = findall(x->x!=0, piece.shape[1,:])[1]-1 # zero indexed (at least one solution otherwise the piece is badly shaped)
    x -= offset

    # check dimensions
    if size(piece)[2] + x - 1 > size(board)[2] ||
        size(piece)[1] + y - 1 > size(board)[1] ||
        x < 1 ||
        y < 1
        return false, newboard(board)  # Piece exceeds board space
    end

    view = board.shape[y:y+size(piece)[1]-1, x:x+size(piece)[2]-1]

    if sum(view[piece.shape .!== 0]) == 0  # only replacing zeros with the piece
        temp = newboard(board)
        temp.shape[y:y + size(piece)[1]-1, x:x + size(piece)[2]-1] += piece.shape
        return true, temp
    end
    return false, newboard(board)
end

function compute(i::Integer, j::Integer, board::Board, perms::Vector{Vector{Piece{T}}}, res::Result, potato::Potato)::Result where {T<:Integer}
    # TODO: Don't calculate the second permutations for duplicated pieces
    # i=x, j=y
    while j <= size(board, 1)
        while i <= size(board, 2)
            if board.shape[j, i] == 0  # find the piece that goes here!
                for p_inx in eachindex(perms)
                    piece_potentials = perms[p_inx]
                    for piece in piece_potentials
                        poss, b = place(board, piece, i, j)

                        res.total_placements += 1
                        res.successful_placements += poss

                        if poss
                            remaining = copy(perms)
                            deleteat!(remaining, p_inx)

                            if length(remaining) <= res.best_fit  # we're the best so far
                                if length(remaining) < res.best_fit  # its a new best
                                    res.best_fit = length(remaining)
                                    res.best_times = 0
                                end
                                res.best_times += 1
                                eat!(potato, b, res, remaining)  # callback for if the piece is the best
                            end

                            if length(remaining) == 0  # We're done!
                                @debug "Found solution" num=res.best_times b
                                push!(res.solutions, b)
                                eat!(potato, b, res, remaining)
                            else
                                compute(i, j, b, remaining, res, potato)
                                # next loop will increment i,j for us
                            end
                        end
                    end
                end
                # Unable to place any pieces. So this sim sucks
                res.dead_ends += 1
                res.duration = (now()-res.tic).value
                return res
            end
            i += 1
        end
        j += 1
        i = 1
    end
    res.duration = (now()-res.tic).value
    return res
end


function distribute(problem::Problem)::Vector{Problem}
    # Turn one problem in a group of subproblems which can then be solved
    # Each subproblem is the board with one of the pieces placed
    subproblems = Problem[]

    # Get initial nonzero position
    x = findall(iszero, problem.board.shape[1,:])[1]
    y = 1  # assume there is at least one nonzero in the first row

    perms = create_permutations(problem.pieces)
    for (permi, perm) in enumerate(perms)
        for piece in perm
            poss, b = place(problem.board, piece, x, y)
            if poss
                # Create a subproblem
                remaining = copy(problem.pieces)
                popat!(remaining, permi)
                push!(subproblems, Problem(remaining, b))
            end
        end
    end
    return subproblems
end


solve(prob::Problem; threaded=false) = solve(prob, defaultpotato(), threaded=threaded)
function solve(problem::Problem, potato::Potato; threaded=false)::Result
    if threaded
        potato.threaded = threaded  # sync
        # Solve the problem using multithreading
        if nthreads() < 2
            @warn "Multithreading arguement badly set. Only using 1 thread. Start julia with --threads=n to add more threads or --threads=auto to set automatically."
        end

        subprobs = distribute(problem)
        nprobs = length(subprobs)
        results = Vector{Result}(undef, nprobs)  # stats for each subproblem to mutate

        @info "Multithreading with $(nthreads()) threads chugging through $(length(subprobs)) subproblems"

        @threads for i = 1:nprobs
            subprob = subprobs[i]
            results[i] = compute(1, 1, subprob.board, create_permutations(subprob.pieces), Result(), potato)
            finished(potato, i, results[i])
        end

        # merge results
        merged = merge(results)
        @info "Found $(length(merged.solutions)) solutions."
        return merged
    end

    perms = create_permutations(problem.pieces)
    return compute(1, 1, problem.board, perms, Result(), potato)
end
# d7320 (init)
# d7844 (julia)
# Algorithm core


# convention
# 0 = empty space
# -1 = outside
# char = filled space of piece corresponding to the char

using Dates  # for now()


function rotate(piece::Piece)::Piece
    """Rotate a piece 90 degrees clockwise""" 
    return newpiece(rotr90(piece.shape))
end


function rotate!(piece::Piece)
    """Rotate a piece 90 clockwise in place"""
    piece.shape = rotr90(piece.shape)
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

create_permutations()::Vector{Vector{Piece}} = create_permutations(create_pieces())  # default
function create_permutations(pieces::Vector{Piece{T}})::Vector{Vector{Piece}} where {T<:Integer}
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

function place(board::Board, piece::Piece, x::Integer, y::Integer):: Tuple{Bool, Board}
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

function compute(i::Integer, j::Integer, board::Board, perms::Vector{Vector{Piece}}, stats::Dict, callbacks)    
    # TODO: Make this multithreaded
    # TODO: Don't calculate the second permutations for duplicated pieces
    # i=x, j=y
    while j <= size(board, 1)
        while i <= size(board, 2)
            if board.shape[j, i] == 0  # find the piece that goes here!
                for p_inx in eachindex(perms)
                    piece_potentials = perms[p_inx]
                    for piece in piece_potentials
                        poss, b = place(board, piece, i, j)

                        stats["total_placements"] += 1
                        stats["successful_placements"] += poss
                        callbacks[1](poss, stats)  # callback for if the piece is placed

                        if poss
                            callbacks[2](b)  # callback for if the piece is possible
                            remaining = copy(perms)
                            deleteat!(remaining, p_inx)

                            if length(remaining) <= stats["best_fit"]  # we're the best so far
                                if length(remaining) < stats["best_fit"]  # its a new best
                                    stats["best_fit"] = length(remaining)
                                    stats["best_times"] = 0
                                end
                                stats["best_times"] += 1
                                callbacks[3](b, stats, remaining)  # callback for if the piece is the best
                            end

                            if length(remaining) == 0  # We're done!
                                @debug "Found solution" num=stats["best_times"] b
                                push!(stats["solutions"], b)
                            else
                                compute(i, j, b, remaining, stats, callbacks)
                                # next loop will increment i,j for us
                            end
                        end
                    end
                end
                # Unable to place any pieces. So this sim sucks
                stats["dead_ends"] += 1
                return stats["solutions"]
            end
            i += 1
        end
        j += 1
        i = 1
    end
    return stats["solutions"]
end

solve(prob::Problem) = solve(prob, [(x,y)->nothing, (x)->nothing, (x,y,z)->nothing])
function solve(problem::Problem, f)
    perms = create_permutations(problem.pieces)
    stats = Dict( # environment variables passed through
        "total_placements" => 0,
        "successful_placements" => 0,
        "dead_ends" => 0,
        "best_fit" => 1000,  # best number of pieces fitted in the board
        "best_times" => 0,  # number of times the best fit was achieved
        "solutions" => [],
        "wait" => false,  # if we wait after each placement for the enter key
        "tic" => now(),  # start time
    )
    return compute(1, 1, problem.board, perms, stats, f)
end

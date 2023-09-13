# d7320 (init)
# d7844 (julia)
# Algorithm core


# convention
# 0 = empty space
# -1 = outside
# char = filled space of piece corresponding to the char

using Dates  # for now()

module core

function create_pieces()::Vector{Piece}
    """Create all of the valid pieces"""
    red = np.array([[1, 1, 1], [1, 1, 0]])
    cyan = np.array([[1, 1, 1], [1, 0, 0], [1, 0, 0]]) * 2
    orange = np.array([[1, 1, 1], [1, 0, 0]]) * 3
    lime = np.ones((2, 2), dtype=int) * 4
    white = np.array([[1, 1], [1, 0]]) * 5
    yellow = np.array([[1, 1, 1], [1, 0, 1]]) * 6
    blue = np.array([[1, 1, 1, 1], [1, 0, 0, 0]]) * 7
    purple = np.ones((4, 1), dtype=int) * 8
    pink = np.array([[1, 1, 0], [0, 1, 1], [0, 0, 1]]) * 9
    green = np.array([[1, 1, 1, 0], [0, 0, 1, 1]]) * 10
    gray = np.array([[0, 1, 0], [1, 1, 1], [0, 1, 0]]) * 11
    salmon = np.array([[1, 1, 1, 1], [0, 1, 0, 0]]) * 12
    tee = np.array([[1,1,1],[0,1,0],[0,1,0]]) * 14
    zed = np.array([[0,0,1],[1,1,1],[1,0,0]]) * 15
    return [red, cyan, orange, lime, white, yellow, blue, purple, pink, green, gray, salmon]
end


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
    """Return if b is in l"""
    for p in l
        if p == b
            return True
        end
    end
    return False
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


function create_permutations(pieces::Vector{Piece}=nothing)::Vector{Vector{Piece}}
    """Create all the possible permutations (rotations and flips) of all given pieces.
    A list of a list of different ways"""
    all_perms = Vector{Piece}[]
    if pieces === nothing
        pieces = create_pieces()
    end

    for p in pieces
        perms = Piece[]
        for f in 1:2
            for r in 1:4
                if not p in perms
                    append!(perms, p)
                end
                p = rotate(p)
            end
            p = flip(p)
        end
        append!(all_perms, perms)
    end
    return all_perms
end


function create_board()::Board
    """Create a board of correct dimensions"""
    b = zeros(Int64, (9, 9))
    invalid = 13
    b[4, 3] = invalid  # missing middle piece
    b[7:end, 1] = invalid  # bottom right corner
    b[8:end, 2] = invalid
    b[9, 3] = invalid
    b[1, 7:end] = invalid  # bottom left corner
    b[2, 8:end] = invalid
    b[3, 9] = invalid
    b[6, 8:end] = invalid  # bottom
    b[7, 7:end] = invalid
    b[8, 6:end] = invalid
    b[9, 6:end] = invalid
    return newboard(b)
end


function place(board::Board, piece::Piece, x::Int64, y::Int64):: Union{Bool, Board}
    """Place the piece in the board if possible"""
    # Offset the piece if it is L or +
    offset = findall(x->x!=0, piece.shape[1,:])[1]

    # check dimensions
    if size(piece)[2] + x - offset > size(board)[2] ||
        size(piece)[1] + y > size(board)[1] ||
        x - offset < 0 ||
        y < 0
        return False, board  # Piece exceeds board space
    end

    view = board.shape[y:y + size(piece)[1], x - offset:x + size(piece)[2] - offset]

    if sum(view[piece != 0]) == 0  # only replacing zeros with the piece
        temp = newboard(board)
        temp.shape[y:y + size(piece)[1], x - offset:x + size(piece)[2] - offset] += piece.shape
        return True, temp
    end
    return False, board
end



function compute(board::Board=nothing, perms::Vector{Vector{Piece}}=nothing, i=0, j=0, stats::Dict=nothing, callbacks=nothing)
    if board === nothing  # for if it is the initial call
        board = create_board()
    end
    if perms === nothing
        perms = create_permutations(create_pieces())
    end
    if stats === nothing
        # environment variables passed through
        stats = Dict(
            "total_placements" => 0,
            "successful_placements" => 0,
            "dead_ends" => 0,
            "best_fit" => 100,  # best number of pieces fitted in the board
            "best_times" => 0,  # number of times the best fit was achieved
            "solutions" => [],
            "wait" => false,  # if we wait after each placement for the enter key
            "tic" => now(),  # start time
        )
    end
    if callbacks === nothing
        # Don't do anything by default, if needed another function will add them
        callbacks = [f(x,y)=nothing, g(x)=nothing, h(x,y,z)=nothing]
    end

    # TODO: Make this multithreaded

    # i=x, j=y
    while j < size(board)[1]
        while i < size(board)[2]
            if board[j, i] == 0  # find the piece that goes here!
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
                                append!(stats["solutions"], b)
                            else
                                compute(board=b, perms=remaining, i=i, j=j, stats=stats, callbacks=callbacks)
                                # next loop will increment i,j for us
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
        i = 0
        end
    end
    return stats["solutions"]
end


end # module
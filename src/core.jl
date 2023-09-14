# d7320 (init)
# d7844 (julia)
# Algorithm core


# convention
# 0 = empty space
# -1 = outside
# char = filled space of piece corresponding to the char

using Dates  # for now()


function create_pieces()::Vector{Piece}
    """Create all of the valid pieces"""
    red = [1 1 1; 1 1 0]
    cyan = [1 1 1; 1 0 0; 1 0 0] .* 2
    orange = [1 1 1; 1 0 0] .* 3
    lime = ones(Integer, (2, 2)) .* 4
    white = [1 1; 1 0] .* 5
    yellow = [1 1 1; 1 0 1] .* 6
    blue = [1 1 1 1; 1 0 0 0] .* 7
    purple = ones(Integer, (4, 1)) .* 8
    pink = [1 1 0; 0 1 1; 0 0 1] .* 9
    green = [1 1 1 0; 0 0 1 1] .* 10
    gray = [0 1 0; 1 1 1; 0 1 0] .* 11
    salmon = [1 1 1 1; 0 1 0 0] .* 12
    tee = [1 1 1; 0 1 0; 0 1 0] .* 14
    zed = [0 0 1; 1 1 1; 1 0 0] .* 15
    return map(newpiece, [red, cyan, orange, lime, white, yellow, blue, purple, pink, green, gray, salmon])
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
                if !(p in perms)
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


function create_board()::Board
    """Create a board of correct dimensions"""
    b = zeros(Integer, (9, 9))
    invalid = 13
    b[4, 3] = invalid  # missing middle piece
    b[7:end, 1] .= invalid  # bottom right corner
    b[8:end, 2] .= invalid
    b[9, 3] = invalid
    b[1, 7:end] .= invalid  # bottom left corner
    b[2, 8:end] .= invalid
    b[3, 9] = invalid
    b[6, 8:end] .= invalid  # bottom
    b[7, 7:end] .= invalid
    b[8, 6:end] .= invalid
    b[9, 6:end] .= invalid
    return newboard(b)
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
        return false, board  # Piece exceeds board space
    end

    view = board.shape[y:y+size(piece)[1]-1, x:x+size(piece)[2]-1]

    if sum(view[piece.shape .!== 0]) == 0  # only replacing zeros with the piece
        temp = newboard(board)
        temp.shape[y:y + size(piece)[1]-1, x:x + size(piece)[2]-1] += piece.shape
        return true, temp
    end
    return false, board
end

function compute(; i::Integer=1, j::Integer=1, callbacks=nothing)
    # The initial call
    b = create_board()
    perms = create_permutations(create_pieces())
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
    return compute(i, j, b, perms, stats, callbacks=callbacks)
end


function compute(i::Integer, j::Integer, board::Board, perms::Vector{Vector{Piece}}, stats::Dict; callbacks=nothing)    
    if callbacks === nothing
        # Don't do anything by default, if needed another function will add them
        callbacks = [(x,y)->nothing, (x)->nothing, (x,y,z)->nothing]
    end

    # TODO: Make this multithreaded

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
                                compute(i, j, b, remaining, stats, callbacks=callbacks)
                                # next loop will increment i,j for us
                            end
                        end
                    end
                end
                # Unable to place any pieces. So this sim sucks
                #@debug "Reached a dead end"
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

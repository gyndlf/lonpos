# d7844

using Crayons
using TOML

# update to static in the future
mutable struct Piece{T<:Integer}
    shape::Matrix{T}
end

struct Board{T<:Integer}
    shape::Matrix{T}
end

# Describe the problem to solve
struct Problem{T<:Integer}
    pieces::Vector{Piece{T}}
    board::Board{T}
end

# Constructors
newpiece(shp::Matrix{T}) where {T<:Integer} = Piece(shp)
newpiece(p::Piece) = Piece(copy(p.shape))

newboard(shp::Matrix{T}) where {T<:Integer} = Board(shp)
newboard(b::Board) = Board(copy(b.shape))  # is a copy
function newboard(map::String)
    lns = split(chomp(map), "\n")

    width = length(lns[1])
    warned = false
    for l in lns
        if length(l) !== length(lns[1])
            if !warned
                @warn "Board description is not rectangular... Automatically extending, but this could have unwanted effects."
                warned = true
            end
            width = length(l)>width ? length(l) : width
        end
    end
    
    board = zeros(Int64, length(lns), width)
    for (j,l) in enumerate(lns)
        for (i,k) in enumerate(l)
            board[j,i] = k!== '0' ? 1 : 0
        end
    end

    return newboard(board * INVALID_BOARD)
end



function loadproblem(fname::AbstractString)::Problem
    desc = TOML.parse(read(fname, String))

    b = newboard(desc["board"])

    return Problem(create_pieces(), b)
end

# Will be removed
function create_pieces()::Vector{Piece{Int64}}
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

# Will be removed
function create_board()::Board{Int64}
    """Create a board of correct dimensions"""
    b = zeros(Int64, (9, 9))
    invalid = INVALID_BOARD
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

Base.:(==)(p::Piece, q::Piece) = p.shape == q.shape

# useful to overload Base.size
Base.size(p::Piece) = size(p.shape)
Base.size(b::Board) = size(b.shape)
Base.size(b::Board, d::T) where {T<:Integer} = size(b)[d]

const colormap = repeat(
    [crayon"bg:(0,0,0)",
    crayon"bg:(230,25,75)",
    crayon"bg:(60,180,75)",
    crayon"bg:(255,255,25)",
    crayon"bg:(0,130,200)",
    crayon"bg:(245,130,48)",
    crayon"bg:(145,30,180)",
    crayon"bg:(70,240,240)",
    crayon"bg:(240,50,230)",
    crayon"bg:(250,190,212)",
    crayon"bg:(0,128,128)",
    crayon"bg:(220,190,255)",
    crayon"bg:(170,110,40)",
    Crayon(background=:default)
    ], 2)

function print_color_matrix(io::IO, M::AbstractArray)
    s = "\n"
    for l in 1:size(M, 1)
        s *= join(map(x->colormap[x+1]("  "), M[l,:])) * "\n"
    end
    print(io, chomp(s))
end

function Base.show(io::IO, b::Board)  # use colours
    print_color_matrix(io, b.shape) 
end

function Base.show(io::IO, p::Piece)
    s = "\n"
    for l in 1:size(p.shape, 1)
        s *= join(map(x->colormap[x+1]("  "), p.shape[l,:])) * "\n"
    end
    print(io, chomp(s))
end

function Base.show(io::IO, prob::Problem)
    println(io, "Lonpos problem with $(typeof(prob.board)),", prob.board)

    maxwidth = displaysize(stdout)[2] ÷ 2  # division as each pixel is "  "
    i = 0
    height = 0

    print(io, "And $(typeof(prob.pieces[1])) ")
    
    toprint = Piece[]
    for p in prob.pieces 
        if i + size(p.shape, 2) + 1 >= maxwidth # flush the pieces
            M = ones(Integer, height, i) * INVALID_BOARD
            inx = 1
            for p in toprint  # know the size is correct
                M[1:size(p.shape,1), inx:size(p.shape,2)+inx-1] = p.shape
                inx += size(p.shape,2) + 1
            end
            print_color_matrix(io, M)
            i = 0
            toprint = Piece[]
            height = 0
        end
        # Add the piece to the stack
        i += size(p.shape, 2) + 1
        height = size(p.shape,1)>height ? size(p.shape,1) : height
        push!(toprint, p)
    end
    # convert to a matrix and print that like the board
    M = ones(Integer, height, i) * INVALID_BOARD
    inx = 1
    for p in toprint  # know the size is correct
        M[1:size(p.shape,1), inx:size(p.shape,2)+inx-1] = p.shape
        inx += size(p.shape,2) + 1
    end
    print_color_matrix(io, M)
end

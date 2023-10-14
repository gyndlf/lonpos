# d7844

using Crayons
using TOML
using Dates

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

# Contain all the solutions and stats. This is passed between branches
mutable struct Result{T<:Integer}
    total_placements::T
    successful_placements::T
    dead_ends::T
    best_fit::T  # best number of pieces fitted in the board
    best_times::T  # number of times the best fit was achieved
    solutions:: Vector{Board}
    tic:: DateTime  # problem start time
end

warned = false

function string_map_to_matrix(map::String)::Matrix{Int64}
    lns = split(chomp(map), r"[;\n]")
    width = length(lns[1])
    for l in lns
        if length(l) !== length(lns[1])
            if !warned
                @warn "Piece/Board description is not rectangular... Automatically extending, but this could have unwanted effects."
                global warned = true
            end
            width = length(l)>width ? length(l) : width
        end
    end
    
    M = zeros(Int64, length(lns), width)
    for (j,l) in enumerate(lns)
        for (i,k) in enumerate(l)
            M[j,i] = k!== '0' ? 1 : 0
        end
    end
    return M
end

# Constructors
newpiece(shp::Matrix{T}) where {T<:Integer} = Piece(shp)
newpiece(p::Piece) = Piece(copy(p.shape))
newpiece(map::String) = newpiece(map, 1)
newpiece(map::String, id::Integer) = newpiece(string_map_to_matrix(map) .* id)

newboard(shp::Matrix{T}) where {T<:Integer} = Board(shp)
newboard(b::Board) = Board(copy(b.shape))  # is a copy
newboard(map::String) = newboard(string_map_to_matrix(map) * INVALID_BOARD)

newresult() = Result(0, 0, 0, 1000, 0, Board[], now())

function merge(results::Vector{Result{T}})::Result{T} where {T<:Integer}
    # Merge all the results into one
    combined = newresult()
    combined.total_placements = sum([r.total_placements for r in results])
    combined.successful_placements = sum([r.successful_placements for r in results])
    combined.dead_ends = sum([r.dead_ends for r in results])
    combined.best_times = sum([r.best_times for r in results])
    combined.solutions = vcat([r.solutions for r in results]...)
    return combined
end

function consistent(prob::Problem)::Bool
    boardgaps = prod(size(prob.board.shape)) - (sum(prob.board.shape)÷13)
    piecegaps = sum([sum(ifelse.(p.shape .!= 0, 1, 0)) for p in prob.pieces])
    return boardgaps == piecegaps
end

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

Base.:(==)(p::Piece, q::Piece) = p.shape == q.shape
Base.:(==)(b::Board, bb::Board) = b.shape == bb.shape

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

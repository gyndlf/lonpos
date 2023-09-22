# d7844

using Crayons

# update to static in the future
mutable struct Piece{T<:Integer}
    shape::Matrix{T}
end

struct Board{T<:Integer}
    shape::Matrix{T}
end

# Constructors
newpiece(shp::Matrix{T}) where {T<:Integer} = Piece(shp)
newboard(shp::Matrix{T}) where {T<:Integer} = Board(shp)

newboard(b::Board) = Board(copy(b.shape))  # is a copy
newpiece(p::Piece) = Piece(copy(p.shape))

# useful to overload Base.size
Base.size(p::Piece) = size(p.shape)
Base.size(b::Board) = size(b.shape)
Base.size(b::Board, d::T) where {T<:Integer} = size(b)[d]

Base.show(io::IO, p::Piece) = print(io, "Piece ", p.shape)

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
function Base.show(io::IO, b::Board)  # use colours
    for l in 1:size(b.shape, 1)
        print(io, join(map(x->colormap[x+1]("  "), b.shape[l,:])), "\n")
    end
end


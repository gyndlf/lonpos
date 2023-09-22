# d7844

using Crayons.Box

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
    [BLACK_BG, RED_BG, GREEN_BG, YELLOW_BG, BLUE_BG, MAGENTA_BG, CYAN_BG, LIGHT_RED_BG, LIGHT_MAGENTA_BG, LIGHT_GREEN_BG, LIGHT_BLUE_BG, LIGHT_YELLOW_BG, DARK_GRAY_BG, DEFAULT_BG],
    2)
function Base.show(io::IO, b::Board)  # use colours
    for l in 1:size(b.shape, 1)
        print(io, join(map(x->colormap[x+1]("  "), b.shape[l,:])), "\n")
    end
end


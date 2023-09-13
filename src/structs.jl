# d7844

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
newpiece(p::Piece) = Piece(p.shape)

# useful to overload Base.size
Base.size(p::Piece) = size(p.shape)
Base.size(b::Board) = size(b.shape)

Base.show(io::IO, p::Piece) = print(io, "Piece ", p.shape)
function Base.show(io::IO, b::Board)
    print(io, "Board $(size(b))\n")
    for l in 1:size(b.shape, 2)
        print(io, join(map(x->length(digits(x)) > 1 ? " $x" : " $x ", b.shape[l,:])), "\n")
    end
end


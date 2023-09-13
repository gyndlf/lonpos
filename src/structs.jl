# d7844
# Apart of Lonpos.core

# update to static in the future
mutable struct Piece
    shape::Matrix{Int64}
end

struct Board
    shape::Matrix{Int64}
end

# Constructors
newpiece(shp::Matrix{Int64}) = Piece(shp)
newboard(shp::Matrix{Int64}) = Board(shp)

newboard(b::Board) = Board(b.shape)  # is a copy
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


# Entrypoint for lonpos.jl

module Lonpos

# Create structs

# update to static in the future
mutable struct Piece
    shape::Matrix{Int64}
end

struct Board
    shape::Matrix(Int64)
end

# Constructors
newpiece(shape::Matrix{Int64}) = Piece(shape)
newboard(shape::Matrix{Int64}) = Board(shape)

newboard(b::Board) = Board(b.shape)  # add a copy?
newpiece(p::Piece) = Piece(p.shape)

# useful to overload Base.size
Base.size(p::Piece) = size(p.shape)
Base.size(b::Board) = size(b.board)


end
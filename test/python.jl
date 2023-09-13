# d7366 (python)
# d7844 (julia)
# Some tests from python imported into julia

# Simple place
b = zeros(Int64, (5,5))
p = ones(Int64, (1,1))
poss, nb = core.place(b, p, 0, 0)
@test poss


# Offset place
b = zeros(Int64, (5,5))
b[0, 0] = 1
p = newpiece([[0, 1, 0], [1, 1, 1], [0, 1, 0]])
poss, nb = core.place(b, p, 1, 0)
@test poss


# Boundary place
p1 = newpiece([[1, 0, 0], [1, 1, 1]]*3)
poss1, b = core.place(core.create_board(), p1, 0, 4)
@test poss1

p2 = newpiece([[1, 1, 1], [1, 0, 1]])
poss, nb = core.place(b, p2, 0, 5)
@test poss == false


# Board creation
board = core.create_board()
p = core.create_pieces()
size0 = sum([sum(po.shape)/(i+1) for (i, po) in enumerate(p)])
size1 = prod(size(board)) - sum(board.shape)/13
@test size0 == size1


# Place the plus shaped piece
b = core.create_board()
p = core.create_pieces()
poss1, b = core.place(b, p[1], 0, 0)
@test poss1

poss, b = core.place(b, p[10], 3, 0)
@test poss

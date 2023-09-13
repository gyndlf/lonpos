# d7366 (python)
# d7844 (julia)
# Some tests from python imported into julia

const newboard = Lonpos.newboard
const newpiece = Lonpos.newpiece
const place = Lonpos.place
const create_board = Lonpos.create_board
const create_pieces = Lonpos.create_pieces

# Simple place
b = newboard(zeros(Integer, (5,5)))
p = newpiece(ones(Integer, (1,1)))
poss, nb = place(b, p, 1, 1)
@debug poss, nb
@test poss


# Offset place
b = newboard(zeros(Int64, (5,5)))
b.shape[1,1] = 1
p = newpiece([0 1 0; 1 1 1; 0 1 0])
poss, nb = place(b, p, 2, 1)
@test poss
@debug nb


# Boundary place
p1 = newpiece([1 0 0; 1 1 1] .*3)
poss1, b = place(create_board(), p1, 1, 5)
@test poss1

p2 = newpiece([1 1 1; 1 0 1])
poss, nb = place(b, p2, 0, 5)
@test poss == false


# Board creation (check the pieces size is the same as the board gaps)
board = create_board()
p = create_pieces()
size0 = sum([sum(po.shape)/i for (i, po) in enumerate(p)])
size1 = prod(size(board)) - sum(board.shape)/13
@test size0 == size1


# Place the plus shaped piece
b = create_board()
p = create_pieces()
poss1, b = place(b, p[1], 1, 1)
@debug b
@test poss1

poss, b = place(b, p[10], 4, 1)
@debug b
@test poss

poss, b = place(b, p[8], 3, 1)
@test poss == false

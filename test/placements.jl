# d7366 (python)
# d7844 (julia)
# Some tests from python imported into julia

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


originalstr = """name = "Original problem"
desc = "Original Lonpos problem with 21,000 solutions according to the box"
version = 1.0


board =  '''
000000111
000000011
000000001
001000000
000000000
000000011
100000111
110001111
111001111
'''

pieces = ["111;110", "111;100;100", "111;100", "11;11", "11;10", "111;101", "1111;1000",
"1111", "110;011;001", "1110;0011", "010;111;010", "1111;0100"]
"""
fname = tempname()
open(fname, "w") do f  # write all
    write(f, originalstr)
end
problem = loadproblem(fname)

# Board creation (check the pieces size is the same as the board gaps)
b = problem.board
p = problem.pieces
size0 = sum([sum(po.shape)/i for (i, po) in enumerate(p)])
size1 = prod(size(b)) - sum(b.shape)/13
@test size0 == size1

# Boundary place
p1 = newpiece([1 0 0; 1 1 1] .*3)
poss1, nb = place(b, p1, 1, 5)
@test poss1

p2 = newpiece([1 1 1; 1 0 1])
poss, nb = place(b, p2, 0, 5)
@test poss == false

# Place the plus shaped piece
poss1, b = place(b, p[1], 1, 1)
@debug b
@test poss1

poss, b = place(b, p[10], 4, 1)
@debug b
@test poss

poss, b = place(b, p[8], 3, 1)
@test poss == false

# Placement tests
p1 = newpiece([1 1 1; 1 0 1])
p2 = newpiece([0 0 1; 1 1 1] .*3)
poss, nb = place(b, p1, 6, 3)
@test poss
@debug nb
poss, nb = place(nb, p2, 9, 4)
@test poss
@test nb.shape[4,9] == 3
# Placement tests

p1 = newpiece([1 1 1; 1 0 1])
p2 = newpiece([0 0 1; 1 1 1] .*3)
poss, b = place(create_board(), p1, 6, 3)
@test poss
@debug b
poss, nb = place(b, p2, 9, 4)
@test poss
@test nb.shape[4,9] == 3
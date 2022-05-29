import lonpos
import time
# View some solutions
# lonpos.view(path)

tic = time.time()

# Place some pieces
perms = lonpos.core.create_permutations(lonpos.core.create_pieces())
for first_place in range(len(perms)):
    print(f"New piece: {first_place}\n {perms[first_place][0]}")
    orientations = 0
    for starting_piece in perms[first_place]:
        b = lonpos.core.create_board()
        p = lonpos.core.create_pieces()

        path = "solutions/" + str(first_place) + "/" + str(orientations) + "_orientations.npy"

        poss, b = lonpos.core.place(b, starting_piece, 0, 0)

        if poss and b[0, 0] != 0:  # filled up the corner
            print(f"New orientation: {orientations}\n {starting_piece}")
            p.pop(first_place)
            lonpos.fast(path, board=b, pieces=p)
            orientations += 1

print(f"Took {(time.time()-tic)/3600} hours")

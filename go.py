import lonpos
import time
# View some solutions
# lonpos.view(path)

tic = time.time()

# Place some pieces
for first_place in range(12):
    for rotates in range(4):
        print("New solution")
        b = lonpos.core.create_board()
        p = lonpos.core.create_pieces()

        path = "solutions/" + str(first_place) + "/" + str(rotates) + "_rotates.npy"

        f = p[first_place]
        for i in range(rotates):
            f = lonpos.core.rotate(f)

        print("Initial piece of\n", f)

        _, b = lonpos.core.place(b, f, 0, 0)
        p.pop(first_place)

        print("Initial board of\n", b)

        lonpos.fast(path, board=b, pieces=p)

print(f"Took {(time.time()-tic)/3600} hours")

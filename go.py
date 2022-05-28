import lonpos

path = "solutions/triangle_upper.npy"

# View some solutions
lonpos.view(path)


# Place some pieces
b = lonpos.core.create_board()
p = lonpos.core.create_pieces()
_, b = lonpos.core.place(b, p[1], 0, 0)
p.pop(1)

lonpos.live(b, p)

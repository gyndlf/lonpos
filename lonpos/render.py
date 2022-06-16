# d7374
# Render all the solutions into a nice picture

import numpy as np
import png


# Pixels are not a new dimension, but just listed next to each other in the ndarray
# [R,G,B, R,G,B, R,G,B],
# [R,G,B, R,G,B, R,G,B]

def to_rgb(val: int) -> list:
    """Convert an int to an appropriate RGB value"""
    # Referenced https://sashamaps.net/docs/resources/20-colors/ for the colours
    colours = [  # these should be fixed based on the piece inputs
        [0, 0, 0],  # 0, black (empty space)
        [230, 25, 75],  # 1, red
        [70, 240, 240],  # 2, light blue (cyan)
        [245, 130, 48],  # 3, orange
        [210, 245, 80],  # 4, lime
        [255, 250, 200],  # 5, white (beige)
        [255, 255, 25],  # 6, yellow
        [0, 130, 200],  # 7, dark blue
        [145, 30, 180],  # 8, purple
        [240, 50, 230],  # 9, magenta
        [60, 180, 75],  # 10, green
        [128, 128, 128],  # 11, gray
        [255, 215, 180],  # 12, salmon (salmon)
        [0, 0, 0]  # was [255, 255, 255] but it doesn't look as good # 13, white (invalid space)
    ]
    if 0 > val or val > 13:
        print(f"Invalid colour {val}")
        return [0, 0, 0]
    return colours[val]


def to_pixels(board: np.ndarray) -> np.ndarray:
    """Convert from different integers to pixels with colour"""
    pic = np.zeros((board.shape[0], board.shape[1]*3), dtype=np.uint8)
    for i in range(board.shape[0]):  # y
        for j in range(board.shape[1]):  # x
            # For each pixel lookup the RGB colour
            pic[i, j*3:(j+1)*3] = to_rgb(board[i, j])
    return pic


def rotate45(a: np.ndarray) -> np.ndarray:
    """Rotate the array by 45 degrees clockwise"""
    # numpy doesn't support this, and scipy changes the values of the array, so I implemented it myself
    rot = np.zeros((a.shape[1]+a.shape[0]-1, a.shape[1]+a.shape[0]-1), dtype=np.uint8)
    mid = (a.shape[1]+a.shape[0]-1)//2
    for i in range(a.shape[0]):  # rows
        for j in range(a.shape[1]):  # columns
            rot[i+j, mid+j] = a[i, j]
        mid -= 1
    return rot[:13, 3:14]  # resize it too


def zoom(pic: np.ndarray, factor: int) -> np.ndarray:
    """Zoom into the array. (Duplicate pixels by the given factor)"""
    return np.kron(pic, np.ones((factor, factor))).astype(int)


def save(board: np.ndarray, path: str = "board.png"):
    """Save the board to a png file"""
    png.fromarray(board, mode='RGB').save(path)


def render(b: np.ndarray, scaling:int = 3) -> np.ndarray:
    """Render the board"""
    return to_pixels(zoom(b, scaling))


def tile(boards: np.ndarray, border = False) -> np.ndarray:
    """Tile 4 boards together with mirroring"""
    assert boards.shape[0] == 4
    i = 0
    if border:
        boards = np.pad(boards, 1)
        i = 1
    c = np.concatenate((np.flip(boards[i]), np.flip(boards[i+1], axis=0)), axis=1)
    d = np.concatenate((np.flip(boards[i+2], axis=1), boards[i+3]), axis=1)
    return np.concatenate((c, d), axis=0)


def tile_strip(boards: np.ndarray, border = False) -> np.ndarray:
    """Repeatedly tile a series of boards"""
    t = np.zeros((boards.shape[1]*2, boards.shape[2]*boards.shape[0]//2), dtype=np.uint8)
    print(boards.shape, t.shape)
    for i in range(boards.shape[0]//4):
        t[:, i*2*boards.shape[2]:(i+1)*2*boards.shape[2]] = tile(boards[i*4:i*4+4], border)
    return t


if __name__ == "__main__":
    c = np.random.randint(0, 13, (20, 20), dtype=np.uint8)
    b = np.load("../solutions/triangle_upper.npy")

    save(render(tile_strip(b)))

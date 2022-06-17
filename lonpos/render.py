# d7374
# Render all the solutions into a nice picture

import numpy as np
import png
import os
import hilbert


# Pixels are not a new dimension, but just listed next to each other in the ndarray
# [R,G,B, R,G,B, R,G,B],
# [R,G,B, R,G,B, R,G,B]

def to_rgb(val: int) -> list:
    """Convert an int to an appropriate RGB value"""
    # Referenced https://sashamaps.net/docs/resources/20-colors/ for the colours
    blank = [255, 255, 255]

    colours = [  # these should be fixed based on the piece inputs
        blank,  # 0, black (empty space)
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
        blank  # 13, white (invalid space)
    ]
    if 0 > val or val > 13:
        print(f"Invalid colour {val}")
        return [0, 0, 0]
    return colours[val]


def to_pixels(board: np.ndarray) -> np.ndarray:
    """Convert from different integers to pixels with colour"""
    print("Converting to pixels")
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
    print(f"Saved to {path}")
    png.fromarray(board, mode='RGB').save(path)


def render(b: np.ndarray, scaling:int = 3) -> np.ndarray:
    """Render the board"""
    return to_pixels(zoom(b, scaling))


def tile(boards: list) -> np.ndarray:
    """Tile 4 boards together with mirroring"""
    assert len(boards) == 4
    c = np.concatenate((np.zeros((boards[0].shape[0], 1)), np.flip(boards[0]), np.zeros((boards[0].shape[0], 1)),
                            np.flip(boards[1], axis=0)), axis=1)
    d = np.concatenate((np.zeros((boards[0].shape[0], 1)), np.flip(boards[2], axis=1),
                        np.zeros((boards[0].shape[0], 1)), boards[3]), axis=1)
    return np.concatenate((np.zeros((1, boards[0].shape[0]*2+2,)), c, np.zeros((1, boards[0].shape[0]*2+2,)), d), axis=0)


def stack(boards: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Repeatedly tile a series of boards, returning the residual"""
    if boards.size == 0:
        print("Empty solution set? Skipping")
        return np.array([]), np.array([])
    t = np.zeros((boards.shape[0]//4, boards.shape[1]*2+2, boards.shape[2]*2+2), dtype=np.uint8)
    for i in range(boards.shape[0]//4):
        t[i, :, :] = tile(boards[i*4:i*4+4])
    print(f"Tiled {boards.shape[0]} boards ({boards.shape[0]//4}) into {t.shape}")
    return t, boards[boards.shape[0]//4*4:]


def merge(solutions: list, length: int = 50) -> np.ndarray:
    """Merge a series of solutions into strips of a set length. Main method"""
    petalx = solutions[0][0].shape[1]*2+2
    petaly = solutions[0][0].shape[0]*2+2

    merged = np.zeros((petaly*21200//(4*length), length*petalx), dtype=np.uint8)
    print(f"Merged shape of {merged.shape}")
    i = 0
    j = 0
    leftovers = []
    for solution_set in range(len(solutions)):
        sols, res = stack(solutions[solution_set])
        leftovers.append(res)
        for s in range(sols.shape[0]):
            merged[j*petaly:(j+1)*petaly, i*petalx:(i+1)*petalx] = sols[s]
            i += 1
            if i >= length:
                i = 0
                j += 1
    print("Solutions merged")
    return merged


def hilbert_merge(solutions: list, length: int = 50) -> np.ndarray:
    """Merge all the solutions together along a Hilbert curve approximation"""
    print("Merging along a hilbert curve")
    all = np.concatenate(solutions)
    map = hilbert.bilbert(np.arange(0, all.shape[0]), length)

    x = solutions[0][0].shape[0]
    y = solutions[0][0].shape[1]

    combined = np.zeros((y*map.shape[0], x*length), dtype=np.uint8)
    for i in range(map.shape[0]):
        for j in range(map.shape[1]):
            combined[i*y:(i+1)*y, j*x:(j+1)*x] = all[map[i, j], :, :]
    return combined


def load_solutions(root: str = "./solutions/") -> list:
    """Load all the solutions from the given directory"""
    solutions = []
    for d in os.listdir(root):
        if os.path.isdir(os.path.join(root, d)):
            for f in os.listdir(os.path.join(root, d)):
                if f.endswith(".npy"):
                    m = np.load(os.path.join(root, d, f))
                    if m.size != 0:
                        solutions.append(m)
    print(f"Loaded {len(solutions)} sets of solutions")
    return solutions


if __name__ == "__main__":
    #save(render(merge(load_solutions("../solutions/"), 100)))
    save(render(hilbert_merge(load_solutions("../solutions/"), 200)))

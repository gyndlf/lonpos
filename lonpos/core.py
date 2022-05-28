# d7320
# Algorithm core

import numpy as np
import time


# convention
# 0 = empty space
# -1 = outside
# char = filled space of piece corresponding to the char


def create_pieces() -> list:
    """Create all of the valid pieces"""
    red = np.array([[1, 1, 1], [1, 1, 0]])
    cyan = np.array([[1, 1, 1], [1, 0, 0], [1, 0, 0]]) * 2
    orange = np.array([[1, 1, 1], [1, 0, 0]]) * 3
    lime = np.ones((2, 2), dtype=int) * 4
    white = np.array([[1, 1], [1, 0]]) * 5
    yellow = np.array([[1, 1, 1], [1, 0, 1]]) * 6
    blue = np.array([[1, 1, 1, 1], [1, 0, 0, 0]]) * 7
    purple = np.ones((4, 1), dtype=int) * 8
    pink = np.array([[1, 1, 0], [0, 1, 1], [0, 0, 1]]) * 9
    green = np.array([[1, 1, 1, 0], [0, 0, 1, 1]]) * 10
    gray = np.array([[0, 1, 0], [1, 1, 1], [0, 1, 0]]) * 11
    salmon = np.array([[1, 1, 1, 1], [0, 1, 0, 0]]) * 12
    tee = np.array([[1,1,1],[0,1,0],[0,1,0]]) * 14
    zed = np.array([[0,0,1],[1,1,1],[1,0,0]]) * 15
    return [red, cyan, orange, lime, white, yellow, blue, purple, pink, green, gray, salmon]


def rotate(piece: np.ndarray) -> np.ndarray:
    """Rotate a piece 90 degrees clockwise"""
    return np.rot90(piece)


def flip(piece: np.ndarray) -> np.ndarray:
    """Flip a piece 180 degrees"""
    return np.flip(piece, 1)  # flip along the vertical line of symmetry


def is_in(l:list, b:np.ndarray) -> bool:
    """Return if b is in l"""
    for p in l:
        if p.shape == b.shape and np.all(p == b):
            return True
    return False


def save_solutions(sols: list, path: str):
    """Save the solutions to disk"""
    # convert from list to ndarray then save
    sols = np.array(sols)
    print(f"Saving to {path}")
    np.save(path, sols)


def load_solutions(path: str) -> np.ndarray:
    """Load a solution from disk"""
    return np.load(path)


def create_permutations(pieces: list = None) -> list:
    """Create all the possible permutations (rotations and flips) of all given pieces.
    A list of a list of different ways"""
    all_perms = []
    if pieces is None:
        pieces = create_pieces()

    for p in pieces:
        perms = []
        for f in range(2):
            for r in range(4):
                if not is_in(perms, p):
                    perms.append(p)
                p = rotate(p)
            p = flip(p)
        all_perms.append(perms)
    return all_perms


def create_board() -> np.ndarray:
    """Create a board of correct dimensions"""
    b = np.zeros((9, 9), dtype=int)
    invalid = 13
    b[3, 2] = invalid  # missing middle piece
    b[6:, 0] = invalid  # bottom right corner
    b[7:, 1] = invalid
    b[8, 2] = invalid
    b[0, 6:] = invalid  # bottom left corner
    b[1, 7:] = invalid
    b[2, 8] = invalid
    b[5, 7:] = invalid  # bottom
    b[6, 6:] = invalid
    b[7, 5:] = invalid
    b[8, 5:] = invalid
    return b


def place(board: np.ndarray, piece: np.ndarray, x: int, y: int) -> (bool, np.ndarray):
    """Place the piece in the board if possible"""
    # Offset the piece if it is L or +
    offset = np.where(piece[0] != 0)[0][0]

    # check dimensions
    if piece.shape[1] + x - offset > board.shape[1] or piece.shape[0] + y > board.shape[0] or x - offset < 0 or y < 0:
        return False, board  # Piece exceeds board space

    view = board[y:y + piece.shape[0], x - offset:x + piece.shape[1] - offset]

    if np.sum(view[piece != 0]) == 0:  # only replacing zeros with the piece
        temp = board.copy()
        temp[y:y + piece.shape[0], x - offset:x + piece.shape[1] - offset] += piece
        return True, temp
    return False, board


def compute(board: np.ndarray = None, perms: list = None, i=0, j=0, stats: dict = None, callbacks: list = None):
    if board is None:  # for if it is the initial call
        board = create_board()
    if perms is None:
        perms = create_permutations(create_pieces())
    if stats is None:
        # environment variables passed through
        stats = {
            "total_placements": 0,
            "successful_placements": 0,
            "dead_ends": 0,
            "best_fit": 100,  # best number of pieces fitted in the board
            "best_times": 0,  # number of times the best fit was achieved
            "solutions": [],
            "wait": False,  # if we wait after each placement for the enter key
            "tic": time.time(),  # start time
        }
    if callbacks is None:
        # Don't do anything by default, if needed another function will add them
        callbacks = [lambda x,y: None, lambda x: None, lambda x,y,z: None]

    # TODO: Make this multithreaded

    # i=x, j=y
    while j < board.shape[0]:
        while i < board.shape[1]:
            if board[j, i] == 0:  # find the piece that goes here!
                for p_inx in range(len(perms)):
                    piece_potentials = perms[p_inx]
                    for piece in piece_potentials:
                        poss, b = place(board, piece, i, j)
                        stats["total_placements"] += 1
                        stats["successful_placements"] += poss
                        callbacks[0](poss, stats)  # callback for if the piece is placed
                        if poss:
                            callbacks[1](b)  # callback for if the piece is possible
                            remaining = perms.copy()
                            remaining.pop(p_inx)
                            if len(remaining) <= stats["best_fit"]:  # we're the best so far
                                if len(remaining) < stats["best_fit"]:  # its a new best
                                    stats["best_fit"] = len(remaining)
                                    stats["best_times"] = 0
                                stats["best_times"] += 1

                                callbacks[2](b, stats, remaining)  # callback for if the piece is the best

                            if len(remaining) == 0:
                                # Done!
                                stats["solutions"].append(b)
                            else:
                                if stats["wait"]:
                                    a = input("waiting")
                                compute(board=b, perms=remaining, i=i, j=j, stats=stats, callbacks=callbacks)
                                # next loop will increment i,j for us
                # Was unable to place the piece. So this sim sucks
                stats["dead_ends"] += 1
                return stats["solutions"]
            i += 1
        j += 1
        i = 0
    return stats["solutions"]

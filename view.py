# d7320
# View some of the save solutions

from blessings import Terminal
import numpy as np
from lonpos import *


def load(path: str) -> np.ndarray:
    """Load a solution from disk"""
    return np.load(path)


def view(solutions: np.ndarray, i: int):
    """View the appropriate solution"""
    print_board(solutions[i], 5)


if __name__ == "__main__":
    term = Terminal()
    print(term.clear())

    file = "solutions/triangle_upper.npy"

    print(term.bold("Lonpos Visualizer v1.0"), term.green('"It works now!"'))
    print(f"Reading: {file}")

    print(term.move(4, 0))
    print("Viewing solution")

    i = 0
    solutions = load(file)
    try:
        while True:
            view(solutions, i)
            _ = input("Enter for next.")

            i += 1
            if i > solutions.shape[0]:
                i = 0
    except KeyboardInterrupt:
        pass
    finally:
        print(term.move(15, 0))

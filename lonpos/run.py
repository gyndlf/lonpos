# d7320
# Functions to run different versions of the algorithm

from .prints import init_print, print_board, print_place, print_remaining
from .core import load_solutions, compute, create_permutations, save_solutions

import numpy as np


def view(path: str):
    """View all the solutions saved at the path"""
    term = init_print()
    print(term.clear())

    print(term.bold("Lonpos Visualizer v1.0"), term.green('"It works now!"'))
    print(f"Reading: {path}")

    i = 0
    solutions = load_solutions(path)
    try:
        while True:
            print(term.move(3, 0))
            print(term.clear_eol, "Viewing solution", i, "/", len(solutions))
            print_board(term, solutions[i], 4)
            print()
            _ = input("Enter for next solution.")

            i += 1
            if i+1 > solutions.shape[0]:
                i = 0
    except KeyboardInterrupt:
        pass
    finally:
        print(term.move(15, 0))


def live(board: np.ndarray = None, pieces: list = None, path: str = None):
    """Solve the board live"""
    term = init_print()
    print(term.clear())

    print(term.bold("Lonpos Solver v1.0"), term.green('"It works now!"'))

    def best(b, stats, remaining):
        print(term.move(16, 0))
        print("Fitted", term.bold(str(12 - len(remaining)) + "/12"),
              "pieces into the board", term.bold(str(stats["best_times"])), "times")
        print_board(term, b, 17)
        print_remaining(term, remaining)

    # Callback functions
    callbacks = [
        lambda p, stats: print_place(term, p, stats),  # called on each placement with argument if possible (bool)
        lambda b: print_board(term, b, 5),  # called on each successful placement with argument board (ndarray)
        best  # called on each new best fit
    ]

    print(term.move(4, 0))
    print("Current board state:")

    print(term.move(15, 0))
    print("Best board so far:")

    print(term.move(27, 0))
    print("Remaining pieces:")

    perms = create_permutations(pieces)

    try:
        with term.hidden_cursor():
            solutions = compute(board, perms, 0, 0, callbacks=callbacks)
    except KeyboardInterrupt:
        pass
    finally:
        print(term.move(32, 0))
        if path is not None:
            save_solutions(solutions, path)


def fast(path: str, board: np.ndarray = None, pieces: list = None):
    """Run the algorithm fast"""

    solutions = compute(board, create_permutations(pieces), 0, 0)
    print("Found", len(solutions), "solutions")
    save_solutions(solutions, path)

# d7320
# Functions to run different versions of the algorithm

from .prints import init_print, print_board
from .core import load_solutions


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
            print(term.clear_eol, "Viewing solution", i)
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

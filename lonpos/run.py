# d7320
# Functions to run different versions of the algorithm

from .prints import init_print, print_board, print_place, print_remaining
from . import core
from .core import solve, loadproblem
from .saveload import load_solutions, save_solutions
from . import render

import numpy as np
import os
import time


def view(piece: int = 0, orientation: int = 0):
    """View all the solutions saved at the corresponding path"""
    term = init_print()
    print(term.clear())

    path = "./solutions/" + str(piece) + "/" + str(orientation) + "_orientations.npy"

    print(term.bold("Lonpos Visualizer v1.0"), term.green('"It works now!"'))

    i = 0
    solutions = load_solutions(path)
    try:
        while True:
            print(term.move(1, 0))
            print(f"Reading: {path}")
            print()
            print(term.clear_eol, "Viewing solution", i, "/", len(solutions))
            print_board(term, solutions[i], 4)
            print()
            print("Press: (n) for next orientation, (p) for next piece, (q) to quit, or (enter) for another solution")
            key = input("")

            if key == "n":  # next orientation
                oriens = os.listdir("solutions/" + str(piece))
                if str(orientation + 1) + "_orientations.npy" in oriens:
                    orientation += 1
                else:
                    orientation = 0
                path = "./solutions/" + str(piece) + "/" + str(orientation) + "_orientations.npy"
                solutions = load_solutions(path)
                i = 0

            elif key == "p":  # next piece
                pieces = os.listdir("solutions")
                if str(piece + 1) in pieces:
                    piece += 1
                elif str(piece + 2) in pieces:  # so we can skip the + piece
                    piece += 2
                else:
                    piece = 0
                path = "./solutions/" + str(piece) + "/0_orientations.npy"
                solutions = load_solutions(path)
                orientation = 0
                i = 0
            elif key == "q":  # quit
                break
            else:  # next solution
                i += 1
                if i+1 > solutions.shape[0]:
                    i = 0
    except KeyboardInterrupt:
        pass
    finally:
        print(term.move(15, 0))


def live(path: str):
    """Solve the board live"""
    problem = loadproblem(path)
    boardheight = problem.board.shape.shape[0]

    term = init_print()
    print(term.clear())

    print(term.bold("Lonpos Solver v1.0"), term.green('"It works now!"'))

    def best(b, stats, remaining):
        print(term.move(boardheight+7, 0))
        print("Fitted", term.bold(str(12 - len(remaining)) + "/12"),
              "pieces into the board", term.bold(str(stats["best_times"])), "times")
        print_board(term, b.shape, boardheight+8)
        print_remaining(term, remaining, 2*boardheight+9)

    # Callback functions
    callbacks = [
        lambda p, stats: print_place(term, p, stats),  # called on each placement with argument if possible (bool)
        lambda b: print_board(term, b.shape, 5),  # called on each successful placement with argument board (ndarray)
        best  # called on each new best fit
    ]

    print(term.move(4, 0))
    print("Current board state:")

    print(term.move(boardheight+6, 0))
    print("Best board so far:")

    print(term.move(2*boardheight+8, 0))
    print("Remaining pieces:")

    try:
        with term.hidden_cursor():
            solutions = solve(problem, callbacks)
        print(term.move(2*boardheight+13, 0))
        print("Found", len(solutions), "solutions : ")
        print_remaining(term, [[i] for i in solutions], 2*boardheight+14)
    except KeyboardInterrupt:
        print(term.move(2*boardheight+14, 0))
        


def tessellate(root_dir: str, length: int = 50, hilbert: bool = False):
    """Combine many solutions into a tessellation grid of them all"""
    if hilbert:
        render.save(render.render(render.hilbert_merge(render.load_solutions(root_dir), length)), "pictures/hilbert.png")
    else:
        render.save(render.render(render.merge(render.load_solutions(root_dir), length)), "pictures/merged.png")

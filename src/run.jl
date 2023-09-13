# d7320 (python)
# d7844 (julia)
# Functions to run different versions of the algorithm
# Only the core functions are imported into julia

using .core

function live(board: np.ndarray = None, pieces: list = None, path: str = None):
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
    """Run the algorithm fast on the given board and pieces"""
    solutions = compute(board, create_permutations(pieces), 0, 0)
    print("Found", len(solutions), "solutions")
    save_solutions(solutions, path)


def solve(jobid: int, total_jobs: int = 4, pieces: list = None, board: np.ndarray = None):
    """Solve all the combinations fast by allocating through the jobid (0-3) usually"""

    assert 0 <= jobid < total_jobs
    assert 12 % total_jobs == 0  # can split all the jobs up evenly
    to_solve = 12 // total_jobs
    print(f"Running job {jobid} to solve {to_solve} pieces")

    tic = time.time()
    if pieces is None:  # Place some pieces
        perms = create_permutations(core.create_pieces())
        pieces = core.create_pieces()
    else:
        perms = create_permutations(pieces)

    if board is None:  # Create a board
        board = core.create_board()

    for first_place in range(jobid*to_solve, (jobid+1)*to_solve):
        print(f"New piece: {first_place}\n {perms[first_place][0]}")
        orientations = 0
        for starting_piece in perms[first_place]:
            b = board.copy()
            p = pieces.copy()

            path = "solutions/" + str(first_place) + "/" + str(orientations) + "_orientations.npy"

            poss, b = core.place(b, starting_piece, 0, 0)

            if poss and b[0, 0] != 0:  # filled up the corner
                print(f"New orientation: {orientations}\n {starting_piece}")
                p.pop(first_place)
                fast(path, board=b, pieces=p)
                orientations += 1

    print(f"Took {(time.time() - tic) / 3600} hours")


# Find a board that has a single solution

import python_lonpos
import numpy as np

# For the board the data type must be int and 13 corresponds to an invalid location for a piece, everything else 0

board = np.zeros((5, 11), dtype=int)

python_lonpos.live(board)


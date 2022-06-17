# Pseudo-hilbert curve generator. Maps ordered items from an array (1D) to a rectangle (2D)
# in a way that best retains the distances between indexes of the initial array as euclidean distances in the rectangle
#
# Hilbert curves are only possible for powers of 2, so the gilbert() function instead tries to fit as many hilbert
# "blocks" together as possible. This is through a greedy approach and works well enough for my needs
#
# Free for any use, but let me know so I know someone found it useful :)
#
# AUTHOR : James Zingel (2022)


import numpy as np


def d2xy(n: int, d: int):
    """Convert from 1D to 2D via hilbert curve. From wikipedia with modification"""
    x, y, s = 0, 0, 1
    while s < n:
        rx = 1 & (d // 2)
        ry = 1 & (d ^ rx)
        x, y = rot(s, x, y, rx, ry)
        x += s * rx
        y += s * ry
        d //= 4
        s *= 2
    return x, y


def rot(n: int, x: int, y: int, rx: int, ry: int):
    """Rotate or flip the quadrant. From wikipedia"""
    if ry == 0:
        if rx == 1:
            x = n-1-x
            y = n-1-y
        x, y = y, x
    return x, y


def hilbert(l: list) -> np.ndarray:
    """Create a hilbert curve for 2^n only"""
    assert len(l) & len(l)-1 == 0, "Length of list must be a power of 2"
    n = int(np.sqrt(len(l)))
    h = np.zeros((n, n), dtype=np.uint8)
    for d in l:
        x, y = d2xy(n, d)
        h[x, y] = d
    return h


def tile_vertically(l: list, hil: np.ndarray, n: int, repeats: int, xoff: int = 0) -> np.ndarray:
    """Tile blocks of size nxn vertically for repeats times, from l into hil"""
    hilbert_i = 0  # index of the block
    r, v = 0, 0
    while r < repeats:
        bi = 0
        while bi < n * n:
            u, v = d2xy(n, hilbert_i)
            hil[v + n * r, u+xoff] = l[hilbert_i]
            hilbert_i += 1
            bi += 1
        r += 1
    return hil


def tile_horizontally(l: list, hil: np.ndarray, n: int, repeats: int, yoff: int = 0) -> np.ndarray:
    """Tile blocks of size nxn horizontally for repeats times, from l into hil"""
    hilbert_i = 0  # index of the block
    r, u = 0, 0
    while r < repeats:
        bi = 0
        while bi < n * n:
            u, v = d2xy(n, hilbert_i)
            hil[v+yoff, u + n*r] = l[hilbert_i]
            hilbert_i += 1
            bi += 1
        r += 1
    return hil


def bilbert(l: list or np.ndarray, x: int) -> np.ndarray:
    """Create a hilbert curve for y*x"""
    y = len(l)//x
    if len(l) % x != 0:
        print(f"Dimensions do not match a rectangle exactly. Truncating by {len(l) % x} items to {y}x{x}")

    hil = np.zeros((y, x), dtype=int)
    # First tile in as much as possible
    if y > x:
        n = 2 ** int(np.log2(x))
        repeats = y // n
        print(f"Initial vertical expansion from {y} rows ({x}) : by {repeats} blocks of {n}x{n}")
        hil = tile_vertically(l, hil, n, repeats)
        last_x = n  # last_x and last_y are the ends of the last block added
        last_y = repeats * n
        yl = y - repeats * n  # xl and yl are how many columns and rows are left
        xl = x - n
    else:  # Tile horizontally
        n = 2 ** int(np.log2(y))
        repeats = x // n  # how many blocks we can fit
        print(f"Initial horizontal expansion from {x} columns ({y}) : by {repeats} blocks of {n}x{n}")
        hil = tile_horizontally(l, hil, n, repeats)
        last_y = n
        last_x = repeats * n
        xl = x - repeats * n
        yl = y - n
    i = n*n*repeats

    # Now fill in the rest
    while i < x*y:  # keep repeating until all pieces have been placed
        if xl > yl:  # there is more work in the x direction
            n = 2 ** int(np.log2(xl))
            repeats = last_y // n  # how many blocks we can fit
            print(f"Vertical expansion from {yl} rows : by {repeats} blocks of {n}x{n}")
            hil = tile_vertically(l[i:], hil, n, repeats, xoff=last_x)
            last_x += n
            xl -= n
        else:
            n = 2 ** int(np.log2(yl))
            repeats = last_x // n  # how many blocks we can fit
            print(f"Horizontal expansion from {xl} columns : by {repeats} blocks of {n}x{n}")
            hil = tile_horizontally(l[i:], hil, n, repeats, yoff=last_y)
            last_y += n
            yl -= n
        i += n*n*repeats
    return hil


if __name__ == "__main__":
    a = np.arange(0, 100)
    print(hilbert(a[:64]))
    print(bilbert(a, 10))


## OUTPUTS
# [[ 0  1 14 15 16 19 20 21]
#  [ 3  2 13 12 17 18 23 22]
#  [ 4  7  8 11 30 29 24 25]
#  [ 5  6  9 10 31 28 27 26]
#  [58 57 54 53 32 35 36 37]
#  [59 56 55 52 33 34 39 38]
#  [60 61 50 51 46 45 40 41]
#  [63 62 49 48 47 44 43 42]]
# [[ 0.  3.  4.  5. 58. 59. 60. 63. 80. 83.]
#  [ 1.  2.  7.  6. 57. 56. 61. 62. 81. 82.]
#  [14. 13.  8.  9. 54. 55. 50. 49. 84. 87.]
#  [15. 12. 11. 10. 53. 52. 51. 48. 85. 86.]
#  [16. 17. 30. 31. 32. 33. 46. 47. 88. 91.]
#  [19. 18. 29. 28. 35. 34. 45. 44. 89. 90.]
#  [20. 23. 24. 27. 36. 39. 40. 43. 92. 95.]
#  [21. 22. 25. 26. 37. 38. 41. 42. 93. 94.]
#  [64. 67. 68. 71. 72. 75. 76. 79. 96. 99.]
#  [65. 66. 69. 70. 73. 74. 77. 78. 97. 98.]]

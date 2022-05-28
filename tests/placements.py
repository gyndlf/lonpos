# d7366
# Some tests for lonpos.py to make sure that it is working as expected

import unittest
import numpy as np
from lonpos import core


class Tests(unittest.TestCase):
    def test_simple_place(self):
        b = np.zeros((5,5), dtype=int)
        p = np.ones((1,1), dtype=int)
        poss, nb = core.place(b, p, 0, 0)
        self.assertTrue(poss)

    def test_with_offset_place(self):
        b = np.zeros((5, 5), dtype=int)
        b[0, 0] = 1
        p = np.array([[0, 1, 0], [1, 1, 1], [0, 1, 0]])
        poss, nb = core.place(b, p, 1, 0)
        self.assertTrue(poss)

    def test_with_boundary_place(self):
        p1 = np.array([[1, 0, 0], [1, 1, 1]])*3
        poss1, b = core.place(core.create_board(), p1, 0, 4)
        print(b)
        self.assertTrue(poss1)
        p2 = np.array([[1, 1, 1], [1, 0, 1]])
        poss, nb = core.place(b, p2, 0, 5)
        self.assertFalse(poss)

    def test_board_create(self):
        board = core.create_board()
        p = core.create_pieces()
        size = np.sum([np.sum(po)/(i+1) for i, po in enumerate(p)])
        size1 = board.shape[0]*board.shape[1] - np.sum(board)/13
        self.assertEqual(size, size1)

    def test_place_plus(self):
        b = core.create_board()
        p = core.create_pieces()
        poss1, b = core.place(b, p[1], 0, 0)
        self.assertTrue(poss1)
        print(b)
        poss, b = core.place(b, p[10], 3, 0)
        print(b)
        self.assertTrue(poss)


if __name__ == "__main__":
    unittest.main()

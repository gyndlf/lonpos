# d7846
# Code migrated from core.py

import numpy as np


def save_solutions(sols: list, path: str):
    """Save the solutions to disk"""
    # convert from list to ndarray then save
    sols = np.array(sols)
    print(f"Saving to {path}")
    np.save(path, sols)


def load_solutions(path: str) -> np.ndarray:
    """Load a solution from disk"""
    return np.load(path)
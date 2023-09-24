# d7320
# Algorithm core

import os

os.environ["JULIA_PROJECT"] = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "Project.toml")
from julia import Lonpos

# Link to core.jl

# To link julia -> python
# ENV["PYTHON"]= ".../bin/python3"


def solve(problem, callbacks):
    return Lonpos.solve(problem, callbacks)

def loadproblem(fname: str):
    return Lonpos.loadproblem(fname)

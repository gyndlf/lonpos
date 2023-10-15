# Lonpos Solver

[![Build Status](https://github.com/jrzingel/Lonpos/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/jrzingel/lonpos/actions/workflows/CI.yml?query=branch%3Amaster)

An algorithm that solves a little puzzle games where you must fit all the little pieces into a grid without leaving any gaps and using all the pieces. The algorithm works through brute force in a depth-first-search system.

![my favourite solution](pictures/single.png)

For the puzzle shown above the algorithm finds all 21,200 solutions to the puzzle (which is what the outside of the box claims) in around 10 minutes when running with 8 cores. 

See `pictures/` for all the solutions of this specific puzzle in various layouts. `solutions/` contains all the solutions in legacy compressed numpy arrays, use `view()` to view them.

## Usage
This algorithm was originally written in python but converted to julia for performance reasons. While python can still be used to call the julia code, it is highly recommended to simply use julia and python is no longer supported. 

### With Julia
Running with julia can be done by simply activiting the package. An example session using the problem established by "simple.toml" can be done like so
```julia
bash> julia --proj=. --threads=auto

julia> using Lonpos
julia> prob = loadproblem("./problems/original.toml")
...
julia> solution = solve(prob, threaded=true)
    ▶ Worker 3 finished subproblem #22 finding 0 solutions in 0.001 seconds.
    ▶ Worker 1 finished subproblem #32 finding 78 solutions in 27.611 seconds.
    ▶ Worker 2 finished subproblem #12 finding 65 solutions in 29.395 seconds.
    ▶ Worker 1 finished subproblem #33 finding 72 solutions in 14.489 seconds.
    ▶ Worker 3 finished subproblem #23 finding 484 solutions in 53.394 seconds.
    ▶ Worker 1 finished subproblem #34 finding 166 solutions in 14.784 seconds.
    ▶ Worker 4 finished subproblem #1 finding 318 solutions in 58.061 seconds.
    ▶ Worker 2 finished subproblem #13 finding 178 solutions in 32.873 seconds.
(Thread 3) Placement successrate of 14,915,498/192,168,935 = 7.76% of 1361 solutions. 	[71.59 total seconds]
```

### With Python
If using the python methods the binary `julia` should be available system-wide and python will connect to the julia environment specified by `Project.toml`. Make sure this all works before trying to use the example python code...

99% of the methods you want to call are located in `lonpos/run.py` which then interops with `src/core.jl`. The other files are just helper methods and stuff.

A simple example is shown in `go.py` and `go.jl`.

## Problem description
Problems are described using the TOML format of a board and available pieces. A `1` corresponds to either the board boundary or the shape of the piece whereas a `0` denotes empty space.

All trailing `0`s are optional and will automatically be inferred. To create a shape over two lines simply separate each line by a newline (`\n`) or `;`. An example problem is shown below using both methods.

```TOML
name = "Simple problem"
version = "1.0"

board = '''
1
01
000001
000011
'''

pieces = ["1;11", "1111", "1111;001", "11;1", "111;01"]
```

## Extra
If you find this useful let me know, as I'd love to hear about it. Pull requests and issues are welcome.

![all solutions printed](pictures/printed.jpg)

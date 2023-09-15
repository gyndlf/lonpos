# Lonpos Solver

[![Build Status](https://github.com/jrzingel/Lonpos/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/jrzingel/lonpos/actions/workflows/CI.yml?query=branch%3Amaster)

An algorithm that solves a little puzzle game where you must fit all the little pieces into a grid without
leaving any gaps and using all the pieces. I found it really hard to do, so I wanted to create a bot to do it for me,
as well as finding all possible solutions.

![my favourite solution](pictures/single.png)

This algorithm finds 21,200 solutions to the puzzle which is exactly the same as what the outside of the box claims.
Running it on four separate threads, it was able to find them all in under an hour
(Pretty good considering there are millions of possibilities)

Also contained in `render.py` are a bunch of methods to visualise the solutions found, either in the command line or as an image.
Using a [pesudo-hilbert curve](https://gist.github.com/vobenhen/c4455327589094c277e16641d6f4b7ab) these solutions can be laid
out on a grid where the most similar solutions are nearest to each other. This layout can be exactly a hilbert curve if a square is specified (sides length being a power of 2),
however I wanted it to be more generic such as long rectangle of solutions. This means I could hypothetically print out all 21,200 solutions on a 3m roll.... 

See `pictures/` for all the solutions in various layouts. `solutions/` contains all the solutions in compressed numpy arrays, use `view()` to view them.

## Usage
The core algorithm of this program is written in Julia, however it can still be called from python. The disadvantage is that the setup to do this is more convoluted. 

`julia` should be available system-wide and when running from python it will connect to the julia environment specified by `Project.toml`. Make sure this will run before trying to call the python code.

99% of the methods you want to call are located in `lonpos/run.py` which then interops with `src/core.jl`. The other files are just helper methods and stuff.

A simple example is shown in `go.py` and `go.jl`.

`blessings` is for fancy CMD line output and `pypng` is for saving the image.

If you find it useful let me know, as I'd love to hear about it

![all solutions printed](pictures/printed.jpg)

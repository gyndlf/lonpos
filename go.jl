# Julia version

using Pkg; Pkg.activate(".")

using Lonpos

prob = loadproblem("./problems/simple.toml")
live(prob)

prob = loadproblem("./problems/original.toml")
live(prob)

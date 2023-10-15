# Julia version

using Pkg; Pkg.activate(".")

using Lonpos

prob = loadproblem("./problems/simple.toml")
live(prob)

println(solve(prob))
println(solve(prob, threaded=true))

prob = loadproblem("./problems/original.toml")
#live(prob)

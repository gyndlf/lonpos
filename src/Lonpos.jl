# Entrypoint for lonpos.jl

module Lonpos

const INVALID_BOARD = 13

# Includes
include("structs.jl")
include("core.jl")
include("run.jl")

export fast, solve, live, loadproblem
end
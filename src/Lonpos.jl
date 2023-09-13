# Entrypoint for lonpos.jl

module Lonpos

# Includes
include("structs.jl")
include("core.jl")
include("run.jl")

export fast
end
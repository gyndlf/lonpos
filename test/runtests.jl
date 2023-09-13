using Test

ENV["JULIA_DEBUG"] = "all"
using Logging

import Lonpos  # to access all methods use `import` not `using`

@testset "python" include("python.jl")

using Lonpos
using Test

ENV["JULIA_DEBUG"] = "all"
using Logging

@testset "python" include("python.jl")

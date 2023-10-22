using Test

ENV["JULIA_DEBUG"] = "all"
using Logging

using Lonpos  # to access all methods use `import` not `using`

const newboard = Lonpos.newboard
const newpiece = Lonpos.newpiece
const place = Lonpos.place
const create_permutations = Lonpos.create_permutations

@testset "permutations" include("permutations.jl")
@testset "end2end" include("end2end.jl")
@testset "placements" include("placements.jl")
@testset "discovery" include("discovery.jl")

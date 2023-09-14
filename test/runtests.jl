using Test

ENV["JULIA_DEBUG"] = "all"
using Logging

import Lonpos  # to access all methods use `import` not `using`

const newboard = Lonpos.newboard
const newpiece = Lonpos.newpiece
const place = Lonpos.place
const create_board = Lonpos.create_board
const create_pieces = Lonpos.create_pieces

@testset "python" include("python.jl")
@testset "placements" include("placements.jl")

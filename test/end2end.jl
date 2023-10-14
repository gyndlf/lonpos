# End to end tests

@test_throws SystemError loadproblem("this/file/doesnt/exist")

problemstr = """
name = "Simple problem"
version = "1.0"

# 0 = valid, 1 = invlid (boundary)
# Only need to enter 0 for spacings
# Use ';' for a newline

board = '''
1
01
000001
000011
'''

pieces = [
    "1;11", "1111", "1111;001", "11;1", "111;01"
    ]
"""
fname = tempname()  
open(fname, "w") do f  # TOML invalid
    write(f, problemstr[1:160])
end
@test_throws Base.TOML.ParserError loadproblem(fname)

open(fname, "w") do f  # TOML missing pieces
    write(f, problemstr[1:172])
end
@test_throws ArgumentError loadproblem(fname)

open(fname, "w") do f  # write all
    write(f, problemstr)
end
prob = loadproblem(fname)

@test Lonpos.consistent(prob)
@debug prob


# Subproblem test
subproblems = Lonpos.distribute(prob)
@test length(subproblems) == 6


# END TO END
sols = solve(prob)

@test length(sols) == 2


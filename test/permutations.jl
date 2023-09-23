# create_permutations test

p = newpiece(ones(Int64, 2,2))
perms = create_permutations([p])
@debug perms
@test length(perms[1])==1

p = newpiece([1 1 1 0; 0 0 1 1])
perms = create_permutations([p])
@debug perms
@test length(perms[1]) == 8

p1 = newpiece([0 1 0; 1 1 1; 0 1 0])
p2 = newpiece([1 1 1; 1 0 0; 1 0 0])
perms = create_permutations([p1, p2])
@debug perms
@test length(perms[1]) == 1
@test length(perms[2]) == 4

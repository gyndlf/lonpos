# Methods to modify the board shape and discover new puzzles.

# Recursively eliminate the neighbours from one board position
function eliminateneighbours!(map::Matrix, j::Integer, i::Integer)
    for (dy, dx) in [(-1,0), (0,1), (1,0), (0,-1)]
        x = i + dx
        y = j + dy
        if 0 < y <= size(map, 1) && (0 < x <= size(map, 2))
            #@debug (j,i) => (y,x)
            if (map[y,x] !== 0) && (map[y,x] !== INVALID_BOARD)
                map[y,x] = 0
                eliminateneighbours!(map, y, x)
            end
        end
    end
end

# If a board has multiple islands, effecively meaning there are multiple puzzles
# Diagonally linked counts as separate islands
function noislands(b::Board)
    # Find an island of ones, then set all connected ones to zero
    # Search for another island, if it exists
    count = 0
    aux = copy(b.map)
    println(aux)
    for j in 1:size(aux, 1)
        for i in 1:size(aux, 2)
            if (aux[j, i] !== 0) && (aux[j,i] !== INVALID_BOARD)
                # Found an island
                count += 1
                aux[j,i] = 0
                eliminateneighbours!(aux, j, i)
                println(aux)

                if count > 1
                    return false
                end
            end
        end
    end
    return true
end


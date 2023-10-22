# d7320 (python)
# d7844 (julia)
# Functions to run different versions of the algorithm
# Only the core functions are imported into julia

using Crayons.Box
using Dates

function clear_lines(num)
    for _ in 1:num
        print("\r\u1b[K\u1b[A")
    end
    print("\r\u1b[K")  # clear that last line
end

function update_screen(b, res, remain)
    clear_lines(size(b.map, 1)+1)
    print("Placement success rate of ", BOLD("$(res.successful_placements)/$(res.total_placements)"), 
    " with ", BOLD("$(res.dead_ends)"), " dead ends in ", BOLD("$(round(now()-res.tic, Minute))"), ".")  # no newline as print(b) adds one at the beginning
    println(b)
    if length(remain) == 0
        print("Found ", BOLD("$(length(res.solutions))"), " solutions.")
    else
        print("Fitted ", BOLD("$(12-length(remain))/12"), " pieces into the board ", BOLD("$(res.best_times)"), " times.")
    end
end

# Solve the board live. Single threaded and slow.
function live(prob::Problem)

    callbacks = Potato(; func=update_screen)

    println(BOLD("Lonpos Solver v1.1"))
    println(prob.board) 

    result = solve(prob, callbacks)
    clear_lines(size(prob.board.map, 1))

    println("Done! Found $(length(result.solutions)) solutions")
    println(result.solutions)
end



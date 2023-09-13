# d7320 (python)
# d7844 (julia)
# Functions to run different versions of the algorithm
# Only the core functions are imported into julia

function fast(path::String)
    """Run the algorithm fast on the given board and pieces"""
    solutions = compute()
    println("Found $(length(solutions)) solutions")
    #save_solutions(solutions, path)
    @debug "Solutions" sol=solutions
end

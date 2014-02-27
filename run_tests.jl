examples = ["simulateFitzhughNagumoODEs"]

println("Running tests:")

for t in examples
    test_fn = joinpath("test", "$t.jl")
    println("  * $test_fn *")
    include(test_fn)
end

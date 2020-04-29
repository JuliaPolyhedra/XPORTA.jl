using Test

using PORTA

function _test_runner()
    @testset "PORTA.jl" begin

        @testset "integration tests:" begin
            println("running integration tests.")
            include("./integration.jl")
        end

    end
end

# Pkg.test("PORTA") runs from ./test directory. Development tests from root.
dir = pwd()
if occursin(r".*/PORTA\.jl/test$", dir)
    cd(_test_runner, "../")
elseif occursin(r".*PORTA\.jl", dir)
    _test_runner()
else
    println(pwd())
    error("runtests.jl must be run from the ./PORTA.jl or ./PORTA.jl/test directories.")
end

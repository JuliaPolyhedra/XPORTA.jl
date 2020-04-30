using Test

using PORTA

function _test_runner()
    @testset "PORTA.jl" begin

        @testset "unit tests:" begin
            println("running unit tests.")
            include("./unit.jl")
        end

        @testset "integration tests:" begin
            println("running integration tests.")
            include("./integration.jl")
        end

    end
end

# Pkg.test("PORTA") runs from ./test directory. Development tests from root.
dir = pwd()
if occursin(r".*test$", dir)
    cd(_test_runner, "../")
elseif occursin(r".*PORTA", dir)
    _test_runner()
else
    error("runtests.jl is currently running from the $(pwd()) directory with contents $(readdir()). runtests.jl must be run from the ./PORTA or ./PORTA/test directories.")
end

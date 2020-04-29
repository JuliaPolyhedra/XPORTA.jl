using Test

using PORTA

function _test_runner()
    @testset "PORTA.jl" begin

        @testset "integration tests:" begin
            println("running inntegration tests.")
            include("./integration.jl")
        end

    end
end

# Pkg.test("PORTA") runs from ./test directory. Development tests from root.
dir = pwd()
if occursin(r".*/PORTA/test$", dir)
    cd(_test_runner, "../")
elseif occursin(r".*PORTA", dir)
    _test_runner()
else
    error("runtests.jl must be run from the ./PORTA or ./PORTA/test directories.")
end

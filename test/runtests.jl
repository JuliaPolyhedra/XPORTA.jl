using Test

using PORTA

function _test_runner()
    @testset "PORTA.jl" begin

        @testset "unit tests:" begin
            println("running unit tests.")
            for test in readdir("./test/unit/")
                # run only julia files in test directory
                if occursin(r"^.*\.jl$", test)
                    println("./unit/$test")
                    include("./unit/$test")
                end
            end
        end

        @testset "integration tests:" begin
            println("running integration tests.")
            for test in readdir("./test/integration/")
               # run only julia files in test directory
               if occursin(r"^.*\.jl$", test)
                   println("./integration/$test")
                   include("./integration/$test")
               end
           end
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

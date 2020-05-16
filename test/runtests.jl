using Test

using XPORTA

function _test_runner()
    @testset "XPORTA.jl" begin

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

        @testset "regression tests:" begin
            println("running regression tests.")
            for test in readdir("./test/regression/")
                if occursin(r"^.*\.jl$", test)
                    println("./regression/$test")
                    include("./regression/$test")
                end
            end
        end
    end
end

# Pkg.test("XPORTA") runs from ./test directory. Development tests from root.
dir = pwd()
if occursin(r".*test$", dir)
    cd(_test_runner, "../")
elseif occursin(r".*XPORTA", dir)
    _test_runner()
else
    error("runtests.jl is currently running from the $(pwd()) directory with contents $(readdir()). runtests.jl must be run from the ./XPORTA.jl or ./XPORTA.jl/test directories.")
end

using Test

@testset "PORTA.jl" begin

using PORTA

PORTA.greet()

@test PORTA.traf(1) == 2

@test true
    # Write your own tests here.
end

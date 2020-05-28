using Test, XPORTA

@testset "./test/regression/simple_polyhedra" begin
    @testset "Unit 3-cube centered at origin" begin
        cube_poi = POI(vertices=[
            1//2 1//2 1//2; 1//2 1//2 -1//2; 1//2 -1//2 1//2; 1//2 -1//2 -1//2;
            -1//2 1//2 1//2; -1//2 1//2 -1//2; -1//2 -1//2 1//2; -1//2 -1//2 -1//2;
        ])

        ieq = traf(cube_poi)

        @test ieq.dim == 3
        @test ieq.inequalities == [
            0 0 2 1; 0 2 0 1; 2 0 0 1;
            -2 0 0 1; 0 -2 0 1; 0 0 -2 1;
        ]
        @test ieq.equalities == Array{Rational{Int64}}(undef,0,0)
    end
end

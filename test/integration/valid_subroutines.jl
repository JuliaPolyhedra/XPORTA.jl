using Test, XPORTA

@testset "src/valid_subroutines.jl" begin

dir = "./test/files/"

@testset "run_valid()" begin
    @testset "throws DomainError if method_flag is not recognized" begin
        @test_throws DomainError XPORTA.run_valid("-X", [dir*"example1.poi"])
    end
end

@testset "fctp()" begin
    cube_poi = POI(vertices=[
        1 1 1; 1 1 -1; 1 -1 1; 1 -1 -1;
        -1 1 1; -1 1 -1; -1 -1 1; -1 -1 -1;
    ])

    poi_array = XPORTA.fctp([0 0 1 1], cube_poi, dir=dir)
    @test length(poi_array) == 1
    @test poi_array[1].conv_section == [1 1 1;1 -1 1;-1 1 1;-1 -1 1]

    poi_array = XPORTA.fctp([0 0 1 2], cube_poi, dir=dir)
    @test length(poi_array) == 0
end

end

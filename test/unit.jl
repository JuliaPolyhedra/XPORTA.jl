using Test

@testset "src/PORTA.jl" begin

@testset "PORTA.POI()" begin
    using PORTA: POI

    @testset "empty initialization" begin
        poi = POI()

        @test poi.conv_section == Array{Int64}(undef,0,0)
        @test poi.cone_section == Array{Int64}(undef,0,0)
        @test poi.dim ==  0

        poi_vertices = POI(vertices = [1 0;0 0])

        @test poi_vertices.conv_section == [1 0;0 0]
        @test poi_vertices.cone_section == Array{Int64}(undef,0,0)
        @test poi_vertices.dim == 2

        poi_rays = POI(rays = [1 0;0 0])

        @test poi_rays.conv_section == Array{Int64}(undef,0,0)
        @test poi_rays.cone_section == [1 0;0 0]
        @test poi_rays.dim == 2
    end

    @testset "throws DomainError if dimensions don't match" begin
        @test_throws DomainError POI(vertices = [1 0;0 0], rays = [1 0 1;0 0 0])
    end

    @testset "valid initializations" begin
        poi_int_int = POI(vertices=[1 0;0 0], rays = [0 1;2 3;4 5])
        @test typeof(poi_int_int) == POI{Int64,Int64}

        @test poi_int_int.conv_section == [1 0;0 0]
        @test poi_int_int.conv_section isa Array{Int,2}
        @test poi_int_int.cone_section == [0 1;2 3;4 5]
        @test poi_int_int.cone_section isa Array{Int,2}
        @test poi_int_int.dim == 2

        poi_int_rational = POI(vertices = [1 2 3;4 5 6], rays = [1//1 0 0;0 0 0])
        @test typeof(poi_int_rational) == POI{Int64,Rational{Int64}}

        @test poi_int_rational.conv_section == [1 2 3;4 5 6]
        @test poi_int_rational.conv_section isa Array{Int,2}
        @test poi_int_rational.cone_section == [1//1 0 0;0 0 0]
        @test poi_int_rational.cone_section isa Array{Rational{Int},2}
        @test poi_int_rational.dim == 3

        poi_rational_int = POI(vertices=[1//1 0;0 0], rays = [1 1])
        @test typeof(poi_rational_int) == POI{Rational{Int64},Int64}

        @test poi_rational_int.conv_section == [1//1 0;0 0]
        @test poi_rational_int.conv_section isa Array{Rational{Int},2}
        @test poi_rational_int.cone_section == [1 1]
        @test poi_rational_int.cone_section isa Array{Int,2}
        @test poi_rational_int.dim == 2

        poi_rational_rational = POI(vertices=[1//1 1//2], rays = [1 1;2 2;3 3//3])
        @test typeof(poi_rational_rational) == POI{Rational{Int64},Rational{Int64}}

        @test poi_rational_rational.conv_section == [1//1 1//2]
        @test poi_rational_rational.conv_section isa Array{Rational{Int},2}
        @test poi_rational_rational.cone_section == [1 1;2 2;3 3//3]
        @test poi_rational_rational.cone_section isa Array{Rational{Int},2}
        @test poi_rational_rational.dim == 2
    end
end

end

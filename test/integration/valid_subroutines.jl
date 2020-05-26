using Test, XPORTA

@testset "src/valid_subroutines.jl" begin

dir = "./test/files/"

@testset "run_valid()" begin
    @testset "throws DomainError if method_flag is not recognized" begin
        @test_throws DomainError XPORTA.run_valid("-X", [dir*"example1.poi"])
    end
end

@testset "iespo()" begin
    @testset "valid in/equalities for a simple 3-simplex" begin
        simplex_poi = POI(vertices=[1 0 0;0 1 0;0 0 1])

        @testset "tight in/equalities are all valid" begin
            ieq = IEQ(inequalities = [-1 0 0 0; 0 -1 0 0; 0 0 -1 0], equalities = [1 1 1 1])

            valid_ieq = iespo(ieq, simplex_poi, dir=dir)

            @test ieq.inequalities == valid_ieq.inequalities
            @test ieq.equalities == valid_ieq.equalities
        end

        @testset "loose upper bounds inequalities" begin
            ieq = IEQ(inequalities = [-1 0 0 1; 0 -1 0 1; 0 0 -1 1], equalities = [1 1 1 1])

            valid_ieq = iespo(ieq, simplex_poi, dir=dir)

            @test ieq.inequalities == valid_ieq.inequalities
            @test ieq.equalities == valid_ieq.equalities
        end

        @testset "tight inequalities invalid equality" begin
            ieq = IEQ(inequalities = [-1 0 0 0; 0 -1 0 0; 0 0 -1 0], equalities = [1 1 1 2])

            valid_ieq = iespo(ieq, simplex_poi, dir=dir)

            @test ieq.inequalities == valid_ieq.inequalities
            @test ieq.equalities == valid_ieq.equalities
        end

        @testset "invalid inequality among valid inequalities" begin
            ieq = IEQ(inequalities = [-1 0 0 -2; 0 -1 0 0; 0 0 -1 0], equalities = [1 1 1 2])

            valid_ieq = iespo(ieq, simplex_poi, dir=dir, cleanup=false, verbose=true)

            @test ieq.inequalities == valid_ieq.inequalities
            @test ieq.equalities == valid_ieq.equalities
        end

        valid_ieq = iespo(
            IEQ(inequalities = [-1 0 0 1; 0 -1 0 0; 0 0 -1 0],equalities = [1 1 1 1]),
            simplex_poi, dir=dir, cleanup=false, opt_flag = "-v")


    end
end

@testset "posie()" begin
    @testset "valid in/equalities for a simple 3-simplex" begin
        simplex_ieq = IEQ(inequalities = [-1 0 0 0; 0 -1 0 0; 0 0 -1 0], equalities = [1 1 1 1])

        @testset "all points are valid" begin
            poi = POI(vertices = [1 0 0; 0 1 0; 0 0 1])

            valid_poi = posie(simplex_ieq, poi, dir=dir)

            @test poi.conv_section == valid_poi.conv_section
            @test poi.cone_section == valid_poi.cone_section
        end

        @testset "no points are valid by equality and inequality" begin
            poi = POI(vertices = [-1 0 0;0 -1 0;0 0 -1])

            valid_poi = posie(simplex_ieq, poi, dir=dir)

            @test valid_poi.conv_section == Array{Rational{Int}}(undef,0,0)
            @test valid_poi.cone_section == Array{Rational{Int}}(undef,0,0)
        end

        @testset "points satisfy inequalities, but not equality" begin
            poi = POI(vertices = [1//2 0 0;0 1//2 0;0 0 1//2])

            valid_poi = posie(simplex_ieq, poi, dir=dir)

            @test valid_poi.conv_section == Array{Rational{Int}}(undef,0,0)
            @test valid_poi.cone_section == Array{Rational{Int}}(undef,0,0)
        end

        @testset "points satisfy equality, but not inequality" begin
            poi = POI(vertices = [3//2 -1//2 0;0 3//2 -1//2;-1//2 0 3//2])

            valid_poi = posie(simplex_ieq, poi, dir=dir)

            @test valid_poi.conv_section == Array{Rational{Int}}(undef,0,0)
            @test valid_poi.cone_section == Array{Rational{Int}}(undef,0,0)
        end

        @testset "all points satisfy, but are not tight with inequalities" begin
            poi = POI(vertices = [1//2 1//2 0;0 1//2 1//2;1//2 0 1//2])

            valid_poi = posie(simplex_ieq, poi, dir=dir)

            @test valid_poi.conv_section == poi.conv_section
            @test valid_poi.cone_section == Array{Rational{Int}}(undef,0,0)
        end

        @testset "one point does not satisfy and is excluded from output" begin
            poi = POI(vertices = [1 0 0;0 1//2 0;0 0 1])

            valid_poi = posie(simplex_ieq, poi, dir=dir)

            @test valid_poi.conv_section == [1 0 0;0 0 1]
            @test valid_poi.cone_section == Array{Rational{Int}}(undef,0,0)
        end
    end
end

@testset "fctp()" begin
    @testset "tight bounds on a simple 3-cube with sidelength 2" begin
        cube_poi = POI(vertices=[
            1 1 1; 1 1 -1; 1 -1 1; 1 -1 -1;
            -1 1 1; -1 1 -1; -1 -1 1; -1 -1 -1;
        ])

        @testset "single tight facet" begin
            poi_dict = fctp([0 0 1 1], cube_poi, dir=dir)
            @test length(poi_dict) == 1
            @test collect(keys(poi_dict)) == [1]
            @test poi_dict[1].conv_section == [1 1 1;1 -1 1;-1 1 1;-1 -1 1]
        end

        @testset "single loose upper bound facet" begin
            poi_dict = fctp([0 0 1 2], cube_poi, dir=dir)
            @test length(poi_dict) == 0
        end

        @testset "invalid facet for polytope returns violating points" begin
            poi_dict = fctp([0 0 1 1//2], cube_poi, dir=dir)
            @test length(poi_dict) == 1
            @test collect(keys(poi_dict)) == [1]
            @test poi_dict[1].conv_section == [1 1 1;1 -1 1;-1 1 1;-1 -1 1]
        end

        poi_dict = fctp([0 0 1 2;0 0 1 1], cube_poi, dir=dir)
        @test length(poi_dict) == 1
        @test collect(keys(poi_dict)) == [2]
        @test poi_dict[2].conv_section == [1 1 1;1 -1 1;-1 1 1;-1 -1 1]
    end
end

end

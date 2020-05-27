using Test, XPORTA

@testset "src/valid_subroutines.jl" begin

dir = "./test/files/"

@testset "run_valid()" begin
    @testset "throws DomainError if method_flag is not recognized" begin
        @test_throws DomainError XPORTA.run_valid("-X", [dir*"example1.poi"])
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

        @testset "single tight facet returns points on facet" begin
            poi_dict = fctp([0 0 1 1], cube_poi, dir=dir)

            @test collect(keys(poi_dict)) == ["valid", "invalid"]
            @test collect(keys(poi_dict["valid"])) == [1]
            @test poi_dict["valid"][1].conv_section == [1 1 1;1 -1 1;-1 1 1;-1 -1 1]
            @test length(poi_dict["invalid"]) == 0
        end

        @testset "single loose upper bound facet will return nothing" begin
            poi_dict = fctp([0 0 1 2], cube_poi, dir=dir)
            @test length(poi_dict["valid"]) == 0
            @test length(poi_dict["invalid"]) == 0
        end

        @testset "invalid facet for polytope returns violating points" begin
            poi_dict = fctp([0 0 1 1//2], cube_poi, dir=dir)
            @test length(poi_dict["valid"]) == 0
            @test length(poi_dict["invalid"]) == 1
            @test collect(keys(poi_dict["invalid"])) == [1]
            @test poi_dict["invalid"][1].conv_section == [1 1 1;1 -1 1;-1 1 1;-1 -1 1]
        end

        @testset "loose, tight, and invalid facet" begin
            poi_dict = fctp([0 0 1 2;0 0 1 1;0 0 1 1//2], cube_poi, dir=dir)
            @test length(poi_dict["valid"]) == 1
            @test poi_dict["valid"][2].conv_section == [1 1 1;1 -1 1;-1 1 1;-1 -1 1]
            @test poi_dict["invalid"][3].conv_section == [1 1 1;1 -1 1;-1 1 1;-1 -1 1]
        end

        @testset "halfspace containing single vertex is valid for that vertex" begin
            poi_dict = fctp([1 1 1 3], cube_poi, dir=dir)

            @test length(poi_dict["valid"]) == 1
            @test length(poi_dict["invalid"]) == 0

            @test poi_dict["valid"][1].conv_section == [1 1 1]
        end
    end

    @testset "square cone" begin
        square_cone_rays = [1 1 1;1 -1 1;-1 1 1;-1 -1 1]
        square_cone_poi = POI(rays=square_cone_rays)

        @testset "tight bounds" begin
            inequalities = [0 1 -1 0;1 0 -1 0;-1 0 -1 0;0 -1 -1 0]

            poi_dict = fctp(inequalities, square_cone_poi, dir=dir)

            @test length(poi_dict["valid"]) == 4

            @test poi_dict["valid"][1].cone_section == vcat(square_cone_rays[1,:]',square_cone_rays[3,:]')
            @test poi_dict["valid"][2].cone_section == vcat(square_cone_rays[1,:]',square_cone_rays[2,:]')
            @test poi_dict["valid"][3].cone_section == vcat(square_cone_rays[3,:]',square_cone_rays[4,:]')
            @test poi_dict["valid"][4].cone_section == vcat(square_cone_rays[2,:]',square_cone_rays[4,:]')

            @test length(poi_dict["invalid"]) == 0
        end

        @testset "positive z halfspace" begin
            poi_dict = fctp([0 0 -1 0], square_cone_poi, dir=dir)

            @test length(poi_dict["valid"]) == 0
            @test length(poi_dict["invalid"]) == 0
        end

        @testset "loose positive z halfspace" begin
            poi_dict = fctp([0 0 -1 1], square_cone_poi, dir=dir)

            @test length(poi_dict["valid"]) == 0
            @test length(poi_dict["invalid"]) == 0
        end

        @testset "loose parallel bound" begin
            poi_dict = fctp([0 1 -1 1], square_cone_poi, dir=dir)

            @test length(poi_dict["invalid"]) == 0
            @test poi_dict["valid"][1].cone_section == [1 1 1;-1 1 1]
        end

        @testset "loose bound non-parallel" begin
            poi_dict = fctp([0 1 -2 0], square_cone_poi, dir=dir)

            @test length(poi_dict["invalid"]) == 0
            @test length(poi_dict["valid"]) == 0
        end

        @testset "excluding bound" begin
            poi_dict = fctp([0 2 -1 0], square_cone_poi, dir=dir)

            @test length(poi_dict["valid"]) == 0
            @test length(poi_dict["invalid"]) == 1
            @test poi_dict["invalid"][1].cone_section == [1 1 1;-1 1 1]
        end

        @testset "excluding, loose, and tight bounds" begin
            poi_dict = fctp([0 2 -1 0;0 0 -1 1;0 -1 -1 0], square_cone_poi, dir=dir)

            @test length(poi_dict["valid"]) == 1
            @test length(poi_dict["invalid"]) == 1

            @test poi_dict["valid"][3].cone_section == [1 -1 1;-1 -1 1]
            @test poi_dict["invalid"][1].cone_section == [1 1 1;-1 1 1]
        end
    end
end

@testset "XPORTA.iespo()" begin

    # verifes functionality broken within porta.
    # TODO: fix PORTA src to let iespo work properly
    @testset "XPORTA.iespo() fails to do its task" begin
        @testset "valid in/equalities for a simple 3-simplex" begin
            simplex_poi = POI(vertices=[1 0 0;0 1 0;0 0 1])

            @testset "tight in/equalities are all valid" begin
                ieq = IEQ(inequalities = [-1 0 0 0; 0 -1 0 0; 0 0 -1 0], equalities = [1 1 1 1])

                valid_ieq = XPORTA.iespo(ieq, simplex_poi, dir=dir)

                @test ieq.inequalities == valid_ieq.inequalities
                @test ieq.equalities == valid_ieq.equalities
            end

            @testset "loose upper bounds inequalities" begin
                ieq = IEQ(inequalities = [-1 0 0 1; 0 -1 0 1; 0 0 -1 1], equalities = [1 1 1 1])

                valid_ieq = XPORTA.iespo(ieq, simplex_poi, dir=dir)

                @test ieq.inequalities == valid_ieq.inequalities
                @test ieq.equalities == valid_ieq.equalities
            end

            @testset "tight inequalities invalid equality" begin
                ieq = IEQ(inequalities = [-1 0 0 0; 0 -1 0 0; 0 0 -1 0], equalities = [1 1 1 2])

                valid_ieq = XPORTA.iespo(ieq, simplex_poi, dir=dir)

                @test ieq.inequalities == valid_ieq.inequalities
                @test ieq.equalities == valid_ieq.equalities
            end

            @testset "invalid inequalities and equation" begin
                ieq = IEQ(inequalities = [-1 0 0 -2; 0 -1 0 -2; 0 0 -1 -2], equalities = [1 1 1 2])

                valid_ieq = XPORTA.iespo(ieq, simplex_poi, dir=dir)

                @test ieq.inequalities == valid_ieq.inequalities
                @test ieq.equalities == valid_ieq.equalities
            end
        end
    end
end

@testset "vint()" begin
    @testset "invalid upper/lower bounds" begin
        @test_throws DomainError vint(IEQ(inequalities=[-1 0 0 0;0 -1 0 0;0 0 -1 0], upper_bounds = [1 1 1;2 2 2], lower_bounds = [0 0 0]), dir=dir)
        @test_throws DomainError vint(IEQ(inequalities=[-1 0 0 0;0 -1 0 0;0 0 -1 0], upper_bounds = [1 1 1], lower_bounds = [0 0 0;-1 -1 -1]), dir=dir)
        @test_throws DomainError vint(IEQ(inequalities=[-1 0 0 0;0 -1 0 0;0 0 -1 0], upper_bounds = [1 1 1]), dir=dir)
        @test_throws DomainError vint(IEQ(inequalities=[-1 0 0 0;0 -1 0 0;0 0 -1 0], lower_bounds = [0 0 0]), dir=dir)
    end

    @testset "finds vertices of simple polyhedra given complete H-representation" begin
        @testset "unit cube with corner at origin has vertices as integer points" begin
            int_cube_ieq = IEQ(inequalities=[0 0 1 1;0 1 0 1;1 0 0 1;-1 0 0 0;0 -1 0 0;0 0 -1 0], upper_bounds=[1 1 1], lower_bounds=[0 0 0])
            int_cube_poi = vint(int_cube_ieq, dir=dir)

            @test int_cube_poi.conv_section == [
                0 0 0;0 0 1;0 1 0;0 1 1;
                1 0 0;1 0 1;1 1 0;1 1 1;
            ]
            @test length(int_cube_poi.cone_section) == 0
        end

        @testset "vint example from http://co-at-work.zib.de/berlin2009/downloads/2009-09-22/2009-09-22-0900-CR-AW-Introduction-Porta-Polymake.pdf" begin
            example_ieq = IEQ(inequalities=[
                -1 0 0 0 0;0 -1 0 0 0;0 0 -1 0 0;0 0 0 -1 0;1 1 0 0 1;0 1 1 0 1;0 0 1 1 1;1 0 0 1 1;0 1 0 1 1
            ], upper_bounds=[1 1 1 1], lower_bounds=[0 0 0 0])

            example_poi = vint(example_ieq, dir=dir)
            @test example_poi.conv_section == [0 0 0 0;0 0 0 1;0 0 1 0;0 1 0 0;1 0 0 0;1 0 1 0]
        end

        @testset "unit cube centered at origin only has the origin as an integral point" begin
            cube_ieq = IEQ(inequalities=[
                0 0 2 1;0 2 0 1;2 0 0 1;-2 0 0 1;0 -2 0 1;0 0 -2 1
            ], upper_bounds=[1 1 1], lower_bounds=[-1 -1 -1])

            cube_int_poi = vint(cube_ieq, dir=dir)

            @test cube_int_poi.conv_section == [0 0 0]
        end

        @testset "simplex with integral vertices" begin
            simplex_ieq = IEQ(
                inequalities=[-1 0 0 0;0 -1 0 0;0 0 -1 0], equalities=[1 1 1 1],
                upper_bounds=[1 1 1], lower_bounds=[0 0 0]
            )
            simplex_poi = vint(simplex_ieq, dir=dir)

            @test simplex_poi.conv_section == [0 0 1;0 1 0;1 0 0]
        end
    end


    @testset "open linear system" begin
        @testset "positive octant in 3-space" begin
            # bounds completely specify a valid range w/o inequalities
            ieq = IEQ(
                upper_bounds=[1 1 1],
                lower_bounds=[0 0 0]
            )
            poi = vint(ieq, dir=dir)
            @test poi.conv_section == [
                0 0 0;0 0 1;0 1 0;0 1 1;
                1 0 0;1 0 1;1 1 0;1 1 1;
            ]
        end
    end
end

end

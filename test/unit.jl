using Test

@testset "src/PORTA.jl" begin

@testset "PORTA.POI()" begin
    using PORTA: POI

    @testset "empty initialization" begin
        poi = POI()

        @test poi.conv_section == Array{Int64}(undef,0,0)
        @test poi.cone_section == Array{Int64}(undef,0,0)
        @test poi.dim ==  0
        @test poi isa POI{Int64}
        @test poi isa POI

        poi_vertices = POI(vertices = [1 0;0 0])

        @test poi_vertices.conv_section == [1 0;0 0]
        @test poi_vertices.cone_section == Array{Int64}(undef,0,0)
        @test poi_vertices.dim == 2
        @test poi_vertices isa POI{Int64}

        poi_rays = POI(rays = [1 0;0 0])

        @test poi_rays.conv_section == Array{Int64}(undef,0,0)
        @test poi_rays.cone_section == [1 0;0 0]
        @test poi_rays.dim == 2
        @test poi_vertices isa POI{Int64}
    end

    @testset "throws DomainError if dimensions don't match" begin
        @test_throws DomainError POI(vertices = [1 0;0 0], rays = [1 0 1;0 0 0])
    end

    @testset "valid initializations" begin
        poi_int_int = POI(vertices=[1 0;0 0], rays = [0 1;2 3;4 5])
        @test typeof(poi_int_int) == POI{Int64}

        @test poi_int_int.conv_section == [1 0;0 0]
        @test poi_int_int.conv_section isa Array{Int64,2}
        @test poi_int_int.cone_section == [0 1;2 3;4 5]
        @test poi_int_int.cone_section isa Array{Int64,2}
        @test poi_int_int.dim == 2

        poi_int_rational = POI(vertices = [1 2 3;4 5 6], rays = [1//1 0 0;0 0 0])
        @test typeof(poi_int_rational) == POI{Rational{Int64}}

        @test poi_int_rational.conv_section == [1 2 3;4 5 6]
        @test poi_int_rational.conv_section isa Array{Rational{Int64},2}
        @test poi_int_rational.cone_section == [1//1 0 0;0 0 0]
        @test poi_int_rational.cone_section isa Array{Rational{Int64},2}
        @test poi_int_rational.dim == 3

        poi_rational_int = POI(vertices=[1//1 0;0 0], rays = [1 1])
        @test typeof(poi_rational_int) == POI{Rational{Int64}}

        @test poi_rational_int.conv_section == [1//1 0;0 0]
        @test poi_rational_int.conv_section isa Array{Rational{Int64},2}
        @test poi_rational_int.cone_section == [1 1]
        @test poi_rational_int.cone_section isa Array{Rational{Int64},2}
        @test poi_rational_int.dim == 2

        poi_rational_rational = POI(vertices=[1//1 1//2], rays = [1 1;2 2;3 3//3])
        @test typeof(poi_rational_rational) == POI{Rational{Int64}}

        @test poi_rational_rational.conv_section == [1//1 1//2]
        @test poi_rational_rational.conv_section isa Array{Rational{Int64},2}
        @test poi_rational_rational.cone_section == [1 1;2 2;3 3//3]
        @test poi_rational_rational.cone_section isa Array{Rational{Int64},2}
        @test poi_rational_rational.dim == 2
    end
end

@testset "PORTA.IEQ()" begin
    using PORTA: IEQ

    @testset "empty initialization" begin
        null_ieq = IEQ()

        @test null_ieq isa IEQ
        @test null_ieq isa IEQ{Int64}
        @test null_ieq.dim == 0
        @test null_ieq.inequalities == Array{Int64}(undef,0,0)
        @test null_ieq.equalities == Array{Int64}(undef,0,0)
        @test null_ieq.lower_bounds == Array{Int64}(undef,0,0)
        @test null_ieq.upper_bounds == Array{Int64}(undef,0,0)
        @test null_ieq.valid == Array{Int64}(undef,0,0)
        @test null_ieq.elimination_order == Array{Int64}(undef,0,0)
    end

    @testset "simple initializations" begin
        ineq_ieq = IEQ(inequalities = [1//1 0;0 0])
        @test ineq_ieq isa IEQ
        @test ineq_ieq isa IEQ{Rational{Int64}}
        @test ineq_ieq.dim == 1
        @test ineq_ieq.inequalities == [1 0;0 0]
        @test ineq_ieq.equalities == Array{Int64}(undef,0,0)

        eq_ieq = IEQ(equalities = [5//2 3//4 2;1 2 3])
        @test eq_ieq isa IEQ
        @test eq_ieq isa IEQ{Rational{Int64}}
        @test eq_ieq.dim == 2
        @test eq_ieq.equalities == [5//2 3//4 2;1 2 3]
        @test eq_ieq.inequalities == Array{Int64}(undef,0,0)

        ineq_lb_ieq = IEQ(inequalities = [5 3 2;1 2 3], lower_bounds = [-1 0])
        @test ineq_lb_ieq isa IEQ
        @test ineq_lb_ieq isa IEQ{Int64}
        @test ineq_lb_ieq.dim == 2
        @test ineq_lb_ieq.inequalities == [5 3 2;1 2 3]
        @test ineq_lb_ieq.lower_bounds == [-1 0]
    end

    @testset "DomainError is thrown if dimension do not match" begin
        @test_throws DomainError IEQ(inequalities = [1 0;0 0], equalities = [1 2 3;4 5 6])
    end
end

end

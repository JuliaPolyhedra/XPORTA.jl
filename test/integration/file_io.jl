using Test, PORTA

@testset "src/file_io.jl" begin

dir = "./test/files/"

@testset "PORTA.read_poi()" begin
    @testset "error thrown if file not `.poi`" begin
        @test_throws DomainError PORTA.read_poi("./test/files/imaginary_file.txt")
    end

    @testset "read test/files/example1.poi" begin
        poi = PORTA.read_poi("./test/files/example1.poi")
        @test poi isa PORTA.POI{Rational{Int}}
        @test poi.cone_section == [0 0 2//3]
        @test poi.conv_section == [3 3 0; 5//3 1 0; 1 5//2 0]
        @test poi.dim == 3
    end

    @testset "read test/files/example2.poi" begin
        poi = PORTA.read_poi("./test/files/example2.poi")
        @test poi isa PORTA.POI{Rational{Int}}
        @test poi.cone_section == [0 0 1 0 0]
        @test poi.conv_section == [3 3 0 2 3; 1 5//2 0 4 5; 5//3 1 0 1 2]
    end
end

@testset "PORTA.read_ieq()" begin
    @testset "error thrown if file not `.ieq`" begin
        @test_throws DomainError PORTA.read_ieq("./test/files/imaginary_file.txt")
    end

    @testset "read test/files/example1.ieq" begin
        ieq = PORTA.read_ieq("./test/files/example1.ieq")
        @test ieq isa PORTA.IEQ{Rational{Int}}
        @test ieq.dim == 3
        @test ieq.inequalities == [-9 -4 0 -19; 0 0 -1 0; 3 -2 0 3; -1 4 0 9]
        @test ieq.valid == [1 5//2 0]
    end

    @testset "read test/files/example2.ieq" begin
        ieq = PORTA.read_ieq("./test/files/example2.ieq")
        @test ieq.dim == 5
        @test ieq.valid == [3 3 0 2 3]
        @test ieq.lower_bounds == [0 1 2 2 2]
        @test ieq.upper_bounds == [2 2 2 5 5]
        @test ieq.elimination_order ==  [2 0 1 0 3]
        @test ieq.equalities == [27 -28 0 57 -37 0; 0 0 0 -1 1 1]
        @test ieq.inequalities ==  [0 1 0 0 -2  -3; 0 0 -1 0 0 0; 0 -2 0 0 1 0; 0 4//15 0 0 1//15 1]
    end
end

@testset "PORTA.write_poi()" begin
    test_dir = PORTA.make_tmp_dir(dir=dir)

    @testset "filename may end in `.poi`" begin
        filepath = PORTA.write_poi("filename_test.poi", PORTA.POI(vertices=[1 0 0;0 -2 0;0 0 1]), dir=test_dir)
        @test filepath == test_dir * "/filename_test.poi"
    end

    @testset "simple vertices" begin
        @test !isfile("./test/files/porta_tmp/int_vert_test.poi")
        filepath = PORTA.write_poi("int_vert_test", PORTA.POI(vertices=[1 0 0;0 -2 0;0 0 1]), dir=test_dir)
        @test filepath == "./test/files/porta_tmp/int_vert_test.poi"
        @test isfile("./test/files/porta_tmp/int_vert_test.poi")
        written_poi = PORTA.read_poi(filepath)

        @test written_poi.dim == 3
        @test written_poi.conv_section == [1 0 0;0 -2 0;0 0 1]
        @test written_poi.valid == Array{Rational{Int}}(undef, 0, 0)
        @test written_poi.cone_section == Array{Rational{Int}}(undef, 0, 0)
    end

    @testset "simple rays" begin
        @test !isfile("./test/files/porta_tmp/int_ray_test.poi")
        filepath = PORTA.write_poi("int_ray_test", PORTA.POI(rays=[1 2 3;4 5 6;7 8 9], valid=[3 3 3]), dir=test_dir)
        @test filepath == "./test/files/porta_tmp/int_ray_test.poi"
        @test isfile("./test/files/porta_tmp/int_ray_test.poi")
        written_poi = PORTA.read_poi(filepath)

        @test written_poi.dim == 3
        @test written_poi.conv_section == Array{Rational{Int}}(undef, 0, 0)
        @test written_poi.valid == [3 3 3]
        @test written_poi.cone_section == [1 2 3;4 5 6;7 8 9]
    end

    @testset "rational vertices" begin
        filepath = PORTA.write_poi("rational_vert_test", PORTA.POI(vertices=[1//2 3//4;5//6 7//8;0 -1]), dir=test_dir)
        @test filepath == "./test/files/porta_tmp/rational_vert_test.poi"
        written_poi = PORTA.read_poi(filepath)

        @test written_poi.dim == 2
        @test written_poi.conv_section == [1//2 3//4;5//6 7//8;0 -1]
        @test written_poi.valid == Array{Rational{Int}}(undef, 0, 0)
        @test written_poi.cone_section == Array{Rational{Int}}(undef, 0, 0)
    end

    @testset "read-write-read example1/2.poi" begin
        ex1_poi = PORTA.read_poi("./test/files/example1.poi")
        filepath = PORTA.write_poi("ex1_rwr_test", ex1_poi, dir=test_dir)
        @test filepath == "./test/files/porta_tmp/ex1_rwr_test.poi"
        written_poi1 = PORTA.read_poi(filepath)

        @test ex1_poi.dim == written_poi1.dim
        @test ex1_poi.valid == written_poi1.valid
        @test ex1_poi.conv_section == written_poi1.conv_section
        @test ex1_poi.cone_section == written_poi1.cone_section

        ex2_poi = PORTA.read_poi("./test/files/example2.poi")
        filepath = PORTA.write_poi("ex2_rwr_test", ex2_poi, dir=test_dir)
        @test filepath == "./test/files/porta_tmp/ex2_rwr_test.poi"
        written_poi2 = PORTA.read_poi(filepath)

        @test ex2_poi.dim == written_poi2.dim
        @test ex2_poi.valid == written_poi2.valid
        @test ex2_poi.conv_section == written_poi2.conv_section
        @test ex2_poi.cone_section == written_poi2.cone_section
    end

    PORTA.cleanup_porta_tmp(dir=dir)
end

@testset " PORTA.write_ieq()" begin
    test_dir = PORTA.make_tmp_dir(dir=dir)

    @testset "simple inequalities" begin
        @test !isfile("./test/files/porta_tmp/int_ineq_test.ieq")
        filepath = PORTA.write_ieq("int_ineq_test", PORTA.IEQ(inequalities=[1 0 1;0 -2 -2;1 -1 1]), dir=test_dir)
        @test filepath == "./test/files/porta_tmp/int_ineq_test.ieq"
        @test isfile("./test/files/porta_tmp/int_ineq_test.ieq")
        written_ieq = PORTA.read_ieq(filepath)

        @test written_ieq.dim == 2
        @test written_ieq.inequalities == [1 0 1;0 -2 -2;1 -1 1]
    end

    @testset "simple rational equalities" begin
        @test !isfile("./test/files/porta_tmp/rational_eq_test.ieq")
        filepath = PORTA.write_ieq("rational_eq_test", PORTA.IEQ(equalities=[1//2 3//4 -5 4;0 -2//3 -2 0]), dir=test_dir)
        @test filepath == "./test/files/porta_tmp/rational_eq_test.ieq"
        @test isfile("./test/files/porta_tmp/rational_eq_test.ieq")
        written_ieq = PORTA.read_ieq(filepath)

        @test written_ieq.dim == 3
        @test written_ieq.equalities == [1//2 3//4 -5 4;0 -2//3 -2 0]
    end

    @testset "read-write-read for example1/2.ieq" begin
        ex1_ieq = PORTA.read_ieq("./test/files/example1.ieq")
        filepath = PORTA.write_ieq("ex1_rwr_test", ex1_ieq, dir=test_dir)
        @test filepath == "./test/files/porta_tmp/ex1_rwr_test.ieq"
        written_ieq1 = PORTA.read_ieq(filepath)

        @test ex1_ieq.dim  ==  written_ieq1.dim
        @test ex1_ieq.valid  ==  written_ieq1.valid
        @test ex1_ieq.inequalities  ==  written_ieq1.inequalities
        @test ex1_ieq.equalities  ==  written_ieq1.equalities
        @test ex1_ieq.upper_bounds  ==  written_ieq1.upper_bounds
        @test ex1_ieq.lower_bounds  ==  written_ieq1.lower_bounds
        @test ex1_ieq.elimination_order  ==  written_ieq1.elimination_order

        ex2_ieq = PORTA.read_ieq("./test/files/example2.ieq")
        filepath = PORTA.write_ieq("ex2_rwr_test", ex2_ieq, dir=test_dir)
        @test filepath == "./test/files/porta_tmp/ex2_rwr_test.ieq"
        written_ieq2 = PORTA.read_ieq(filepath)

        @test ex2_ieq.dim  ==  written_ieq2.dim
        @test ex2_ieq.valid  ==  written_ieq2.valid
        @test ex2_ieq.inequalities  ==  written_ieq2.inequalities
        @test ex2_ieq.equalities  ==  written_ieq2.equalities
        @test ex2_ieq.upper_bounds  ==  written_ieq2.upper_bounds
        @test ex2_ieq.lower_bounds  ==  written_ieq2.lower_bounds
        @test ex2_ieq.elimination_order  ==  written_ieq2.elimination_order
    end

    PORTA.cleanup_porta_tmp(dir=dir)
end

end

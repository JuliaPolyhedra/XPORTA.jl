using Test

@testset "src/file_io.jl" begin

using PORTA

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

end

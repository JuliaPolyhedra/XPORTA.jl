using Test

@testset "src/file_io.jl" begin

using PORTA

@testset "PORTA.read_poi()" begin
    @testset "error thrown if file not `.poi`" begin
        @test_throws DomainError PORTA.read_poi("./test/files/imaginary_file.txt")
    end

    @testset "read test/files/example1.poi" begin
        poi = PORTA.read_poi("./test/files/example1.poi")
        @test poi isa PORTA.POI{Rational{Int64}, Rational{Int64}}
        @test poi.cone_section == [0 0 2//3]
        @test poi.conv_section == [3 3 0; 5//3 1 0; 1 5//2 0]
        @test poi.dim == 3
    end

    @testset "read test/files/example2.poi" begin
        poi = PORTA.read_poi("./test/files/example2.poi")
        @test poi isa PORTA.POI{Rational{Int64}, Rational{Int64}}
        @test poi.cone_section == [0 0 1 0 0]
        @test poi.conv_section == [3 3 0 2 3; 1 5//2 0 4 5; 5//3 1 0 1 2]
    end
end

end

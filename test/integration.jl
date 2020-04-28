using Test, UUIDs

@testset "PORTA.jl" begin

using PORTA

dir = "./test/files/"

@testset "PORTA.cleanup_porta_tmp()" begin
    @testset "create a file in porta_tmp then cleanup" begin
        # create file without worrying about whether it already exists
        tmp_path = dir * "porta_tmp"
        mkpath(tmp_path)
        tmp_file = string(tmp_path,"/tmp_test.txt")
        write(tmp_file, 2)

        # verify that the created file exists
        @test isfile(tmp_file) == true

        PORTA.cleanup_porta_tmp(dir)

        # verify that file no longer exists
        @test isfile(tmp_file) == false

        # verify that directory is missing causing a SystemError to be thrown
        @test_throws SystemError walkdir(tmp_path)
    end

    @testset "Errors if directory is not provided" begin
        @test_throws MethodError PORTA.cleanup_porta_tmp()
    end

end

end

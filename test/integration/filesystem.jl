using Test, UUIDs, PORTA

@testset "src/filesystem.jl" begin

dir = "./test/files/"

@testset "PORTA.make_porta_tmp()" begin
    @testset "making porta_tmp directory" begin
        # make sure directory does not exist to begin with
        PORTA.rm_porta_tmp(dir)
        @test !isdir(dir*"porta_tmp")

        # porta_tmp directory exists after creation
        tmp_dir_path = PORTA.make_porta_tmp(dir)
        @test isdir(dir*"porta_tmp")
        @test tmp_dir_path == dir*"porta_tmp"

        # porta_tmp directory is missing after creation
        PORTA.rm_porta_tmp(dir)
        @test !isdir(dir*"porta_tmp")
    end
end

@testset "PORTA.rm_porta_tmp()" begin
    @testset "create a file in porta_tmp then cleanup" begin
        # create file without worrying about whether it already exists
        tmp_dir_path = PORTA.make_porta_tmp(dir)
        tmp_file = string(tmp_dir_path,"/tmp_test.txt")
        write(tmp_file, 2)

        # verify that the created directory and file exists
        @test isdir(dir*"porta_tmp")
        @test isfile(tmp_file)

        # verify that file/directory no longer exists after cleanup
        PORTA.rm_porta_tmp(dir)
        @test !isfile(tmp_file)
        @test !isdir(dir*"porta_tmp")

        # verify that directory is missing causing a SystemError to be thrown
        @test_throws SystemError walkdir(tmp_dir_path)
    end
end

end

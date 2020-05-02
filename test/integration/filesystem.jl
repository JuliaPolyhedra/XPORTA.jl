using Test, UUIDs, PORTA

@testset "src/filesystem.jl" begin

dir = "./test/files/"

@testset "PORTA.make_tmp_dir()" begin
    @testset "making porta_tmp directory" begin
        # make sure directory does not exist to begin with
        PORTA.cleanup_porta_tmp(dir=dir)
        @test !isdir(dir*"porta_tmp")

        # porta_tmp directory exists after creation
        tmp_dir_path = PORTA.make_tmp_dir(dir=dir)
        @test isdir(dir*"porta_tmp")
        @test tmp_dir_path == dir*"porta_tmp"

        # porta_tmp directory is missing after creation
        PORTA.cleanup_porta_tmp(dir=dir)
        @test !isdir(dir*"porta_tmp")
    end

    @testset "making custom_tmp directory" begin
        # make sure directory does not exist to begin with
        rm(dir*"custom_tmp", recursive=true, force=true)
        @test !isdir(dir*"custom_tmp")

        # custom_tmp directory exists after creation
        tmp_dir_path = PORTA.make_tmp_dir(dir=dir, tmp_dir="custom_tmp")
        @test isdir(dir*"custom_tmp")
        @test tmp_dir_path == dir*"custom_tmp"

        # custom_tmp directory is missing after creation
        rm(dir*"custom_tmp", recursive=true, force=true)
        @test !isdir(dir*"custom_tmp")
    end
end

@testset "PORTA.cleanup_porta_tmp()" begin
    @testset "create a file in porta_tmp then cleanup" begin
        # create file without worrying about whether it already exists
        tmp_dir_path = PORTA.make_tmp_dir(dir=dir)
        tmp_file = string(tmp_dir_path,"/tmp_test.txt")
        write(tmp_file, 2)

        # verify that the created directory and file exists
        @test isdir(dir*"porta_tmp")
        @test isfile(tmp_file)

        # verify that file/directory no longer exists after cleanup
        PORTA.cleanup_porta_tmp(dir=dir)
        @test !isfile(tmp_file)
        @test !isdir(dir*"porta_tmp")

        # verify that directory is missing causing a SystemError to be thrown
        @test_throws SystemError walkdir(tmp_dir_path)
    end
end

end

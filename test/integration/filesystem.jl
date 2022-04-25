using Test, UUIDs, XPORTA

@testset "src/filesystem.jl" begin

dir = "./test/files/"

@testset "XPORTA.make_porta_tmp()" begin
    @testset "making porta_tmp directory" begin
        # make sure directory does not exist to begin with
        XPORTA.rm_porta_tmp(dir)
        @test !isdir(dir*"porta_tmp")

        # porta_tmp directory exists after creation
        tmp_dir_path = XPORTA.make_porta_tmp(dir)
        @test isdir(dir*"porta_tmp")
        @test tmp_dir_path == dir*"porta_tmp"

        # porta_tmp directory is missing after creation
        XPORTA.rm_porta_tmp(dir)
        @test !isdir(dir*"porta_tmp")
    end
end

@testset "XPORTA.rm_porta_tmp()" begin
    @testset "create a file in porta_tmp then cleanup" begin
        # create file without worrying about whether it already exists
        tmp_dir_path = XPORTA.make_porta_tmp(dir)
        tmp_file = string(tmp_dir_path,"/tmp_test.txt")
        write(tmp_file, 2)

        # verify that the created directory and file exists
        @test isdir(dir*"porta_tmp")
        @test isfile(tmp_file)

        # verify that file/directory no longer exists after cleanup
        XPORTA.rm_porta_tmp(dir)
        @test !isfile(tmp_file)
        @test !isdir(dir*"porta_tmp")
    end
end

end

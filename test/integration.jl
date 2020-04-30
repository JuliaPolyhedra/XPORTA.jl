using Test, UUIDs

@testset "src/PORTA.jl" begin

using PORTA

dir = "./test/files/"

@testset "PORTA.make_tmp_dir()" begin
    @testset "making porta_tmp directory" begin
        # make sure directory does not exist to begin with
        PORTA.cleanup_tmp_dir(dir=dir)
        @test !isdir(dir*"porta_tmp")

        # porta_tmp directory exists after creation
        tmp_dir_path = PORTA.make_tmp_dir(dir=dir)
        @test isdir(dir*"porta_tmp")
        @test tmp_dir_path == dir*"porta_tmp"

        # porta_tmp directory is missing after creation
        PORTA.cleanup_tmp_dir(dir=dir)
        @test !isdir(dir*"porta_tmp")
    end

    @testset "making custom_tmp directory" begin
        # make sure directory does not exist to begin with
        PORTA.cleanup_tmp_dir(dir=dir, tmp_dir="custom_tmp")
        @test !isdir(dir*"custom_tmp")

        # custom_tmp directory exists after creation
        tmp_dir_path = PORTA.make_tmp_dir(dir=dir, tmp_dir="custom_tmp")
        @test isdir(dir*"custom_tmp")
        @test tmp_dir_path == dir*"custom_tmp"

        # custom_tmp directory is missing after creation
        PORTA.cleanup_tmp_dir(dir=dir, tmp_dir="custom_tmp")
        @test !isdir(dir*"custom_tmp")
    end
end

@testset "PORTA.cleanup_tmp_dir()" begin
    @testset "create a file in porta_tmp then cleanup" begin
        # create file without worrying about whether it already exists
        tmp_dir_path = PORTA.make_tmp_dir(dir=dir)
        tmp_file = string(tmp_dir_path,"/tmp_test.txt")
        write(tmp_file, 2)

        # verify that the created directory and file exists
        @test isdir(dir*"porta_tmp")
        @test isfile(tmp_file)

        # verify that file/directory no longer exists after cleanup
        PORTA.cleanup_tmp_dir(dir=dir)
        @test !isfile(tmp_file)
        @test !isdir(dir*"porta_tmp")

        # verify that directory is missing causing a SystemError to be thrown
        @test_throws SystemError walkdir(tmp_dir_path)
    end
end

@testset "PORTA.run_xporta()" begin
    @testset "throws DomainError if method_flag is not recognized" begin
        @test_throws DomainError PORTA.run_xporta("-X", "dir/example1.poi")
    end

    @testset "test traf (xporta -T) with example1.poi" begin
        PORTA.cleanup_tmp_dir(dir=dir)
        PORTA.make_tmp_dir(dir=dir)

        # copy example files into porta_tmp to avoid mutation and creation
        ex1_poi_filepath = cp(dir*"example1.poi", dir*"porta_tmp/example1.poi")

        # run xporta
        PORTA.run_xporta("-T", "$ex1_poi_filepath")

        # verify that created .ieq file contains expected results
        ieq1_string = read(ex1_poi_filepath*".ieq", String)
        match_ieq1_string = read(dir*"example1.ieq", String)
        @test ieq1_string == match_ieq1_string

        PORTA.cleanup_tmp_dir(dir=dir)
    end

    @testset "test traf (xporta -T) with example2.ieq" begin
        PORTA.cleanup_tmp_dir(dir=dir)
        PORTA.make_tmp_dir(dir=dir)

        ex2_ieq_filepath = cp(dir*"example2.ieq", dir*"porta_tmp/example2.ieq")

        PORTA.run_xporta("-T", "$ex2_ieq_filepath")

        poi2_string = read(ex2_ieq_filepath*".poi", String)
        match_poi2_string = read(dir*"example2.poi", String)
        @test poi2_string == match_poi2_string

        PORTA.cleanup_tmp_dir(dir=dir)
    end
end

end

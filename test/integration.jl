using Test, UUIDs

@testset "src/PORTA.jl" begin

using PORTA

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

@testset "PORTA.run_xporta()" begin
    @testset "throws DomainError if method_flag is not recognized" begin
        @test_throws DomainError PORTA.run_xporta("-X", "dir/example1.poi")
    end

    @testset "test traf (xporta -T) with example1.poi" begin
        PORTA.cleanup_porta_tmp(dir=dir)
        PORTA.make_tmp_dir(dir=dir)

        # copy example files into porta_tmp to avoid mutation and creation
        ex1_poi_filepath = cp(dir*"example1.poi", dir*"porta_tmp/example1.poi")

        # run xporta
        PORTA.run_xporta("-T", "$ex1_poi_filepath")

        # verify that created .ieq file contains expected results
        ieq1_string = read(ex1_poi_filepath*".ieq", String)
        match_ieq1_string = read(dir*"example1.ieq", String)
        @test ieq1_string == match_ieq1_string

        PORTA.cleanup_porta_tmp(dir=dir)
    end

    @testset "test traf (xporta -T) with example2.ieq" begin
        PORTA.cleanup_porta_tmp(dir=dir)
        PORTA.make_tmp_dir(dir=dir)

        ex2_ieq_filepath = cp(dir*"example2.ieq", dir*"porta_tmp/example2.ieq")

        PORTA.run_xporta("-T", "$ex2_ieq_filepath")

        # reading .poi files
        poi2 = PORTA.read_poi(ex2_ieq_filepath*".poi")
        poi2_match = PORTA.read_poi(dir*"example2.poi")

        @test poi2.dim == poi2_match.dim
        @test poi2.cone_section == poi2_match.cone_section
        @test poi2.conv_section == poi2_match.conv_section

        PORTA.cleanup_porta_tmp(dir=dir)
    end
end

end

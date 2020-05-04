using Test, PORTA

@testset "src/xporta.jl" begin

dir = "./test/files/"

@testset "run_xporta()" begin
    @testset "throws DomainError if method_flag is not recognized" begin
        @test_throws DomainError PORTA.run_xporta("-X", ["dir/example1.poi"])
    end

    @testset "test traf (xporta -T) with example1.poi" begin
        PORTA.rm_porta_tmp(dir)
        PORTA.make_porta_tmp(dir)

        # copy example files into porta_tmp to avoid mutation and creation
        ex1_poi_filepath = cp(dir*"example1.poi", dir*"porta_tmp/example1.poi")

        # run xporta
        PORTA.run_xporta("-T", [ex1_poi_filepath])

        # verify that created .ieq file contains expected results
        ieq1 = PORTA.read_ieq(ex1_poi_filepath*".ieq")
        match_ieq1 = PORTA.read_ieq(dir*"example1.ieq")
        @test ieq1.dim == match_ieq1.dim
        @test ieq1.inequalities == match_ieq1.inequalities
        @test ieq1.equalities == match_ieq1.equalities
        @test ieq1.lower_bounds == match_ieq1.lower_bounds
        @test ieq1.upper_bounds == match_ieq1.upper_bounds
        @test ieq1.elimination_order == match_ieq1.elimination_order
        @test ieq1.valid == match_ieq1.valid

        PORTA.rm_porta_tmp(dir)
    end

    @testset "test traf (xporta -T) with example2.ieq" begin
        PORTA.rm_porta_tmp(dir)
        PORTA.make_porta_tmp(dir)

        ex2_ieq_filepath = cp(dir*"example2.ieq", dir*"porta_tmp/example2.ieq")

        PORTA.run_xporta("-T", [ex2_ieq_filepath])

        # reading .poi files
        poi2 = PORTA.read_poi(ex2_ieq_filepath*".poi")
        poi2_match = PORTA.read_poi(dir*"example2.poi")

        @test poi2.dim == poi2_match.dim
        @test poi2.cone_section == poi2_match.cone_section
        @test poi2.conv_section == poi2_match.conv_section
        @test poi2.valid == poi2_match.valid

        PORTA.rm_porta_tmp(dir)
    end
end

@testset "traf()" begin
    @testset "test cleanup true/false" begin
        PORTA.rm_porta_tmp(dir)
        @test !isdir(dir*"porta_tmp")
        pre_dir_length = length(readdir(dir))

        traf(POI(vertices = [1 0 0;0 1 0;0 0 1]), dir=dir, filename="traf_test_cleanup")
        traf(IEQ(inequalities = [1 0 0 0;0 0 1 0]), dir=dir, filename="traf_test_cleanup")

        post_dir_length = length(readdir(dir))

        @test pre_dir_length == post_dir_length
        @test !isdir(dir*"porta_tmp")

        pre_dir_length = length(readdir(dir))

        traf(POI(vertices = [1 0 0;0 1 0;0 0 1]), dir=dir, filename="traf_test_cleanup", cleanup=false)
        traf(IEQ(inequalities = [1 0 0 0;0 0 1 0]), dir=dir, filename="traf_test_cleanup", cleanup=false)

        post_dir_length = length(readdir(dir))

        @test pre_dir_length + 4 == post_dir_length
        @test !isdir(dir*"porta_tmp")
        @test isfile(dir * "traf_test_cleanup.poi")
        @test isfile(dir * "traf_test_cleanup.poi.ieq")
        @test isfile(dir * "traf_test_cleanup.ieq")
        @test isfile(dir * "traf_test_cleanup.ieq.poi")

        # removing created fileds
        rm(dir * "traf_test_cleanup.poi")
        rm(dir * "traf_test_cleanup.poi.ieq")
        rm(dir * "traf_test_cleanup.ieq")
        rm(dir * "traf_test_cleanup.ieq.poi")
        @test pre_dir_length == length(readdir(dir))

        PORTA.rm_porta_tmp(dir)
    end

    @testset "example1.poi" begin
        ex1_poi = PORTA.read_poi(dir*"example1.poi")
        ex1_ieq_match = PORTA.read_ieq(dir*"example1.ieq")

        ex1_ieq = traf(ex1_poi, dir=dir)

        @test ex1_ieq.dim == ex1_ieq_match.dim
        @test ex1_ieq.inequalities == ex1_ieq_match.inequalities
        @test ex1_ieq.equalities == ex1_ieq_match.equalities
        @test ex1_ieq.valid == ex1_ieq_match.valid
        @test ex1_ieq.upper_bounds == ex1_ieq_match.upper_bounds
        @test ex1_ieq.lower_bounds == ex1_ieq_match.lower_bounds
        @test ex1_ieq.elimination_order == ex1_ieq_match.elimination_order
    end

    @testset "example2.poi" begin
        ex2_poi = PORTA.read_poi(dir*"example2.poi")
        ex2_ieq_match = PORTA.read_ieq(dir*"example2.ieq")

        ex2_ieq = traf(ex2_poi, dir=dir)

        @test ex2_ieq.dim == ex2_ieq_match.dim
        @test ex2_ieq.inequalities[1:3,:] == ex2_ieq_match.inequalities[1:3,:]
        @test ex2_ieq.inequalities[4,:] == ex2_ieq_match.inequalities[4,:].*15 # last inequality is equivalent upto a global scalar
        @test ex2_ieq.equalities == ex2_ieq_match.equalities
        @test ex2_ieq.valid != ex2_ieq_match.valid

        # both valid points are valid
        @test all(map( row_id ->
            sum(ex2_ieq.inequalities[row_id,1:end-1]'.*ex2_ieq.valid) <= ex2_ieq.inequalities[row_id,end],
            1:size(ex2_ieq.inequalities)[1]
        ))

        @test all(map( row_id ->
            sum(ex2_ieq_match.inequalities[row_id,1:end-1]'.*ex2_ieq_match.valid) <= ex2_ieq_match.inequalities[row_id,end],
            1:size(ex2_ieq_match.inequalities)[1]
        ))
    end

    @testset "example1.ieq" begin
        ex1_ieq = PORTA.read_ieq(dir*"example1.ieq")
        ex1_poi_match = PORTA.read_poi(dir*"example1.poi")

        ex1_poi = traf(ex1_ieq, dir=dir)

        @test ex1_poi.dim == ex1_poi_match.dim
        @test ex1_poi.valid == ex1_poi_match.valid
        @test ex1_poi.conv_section[1] == ex1_poi_match.conv_section[1]
        @test ex1_poi.conv_section[2] == ex1_poi_match.conv_section[3]
        @test ex1_poi.conv_section[3] == ex1_poi_match.conv_section[2]
        @test ex1_poi.cone_section == ex1_poi_match.cone_section*3/2
    end

    @testset "example2.ieq" begin
        ex2_ieq = PORTA.read_ieq(dir*"example2.ieq")
        ex2_poi_match = PORTA.read_poi(dir*"example2.poi")

        ex2_poi = traf(ex2_ieq, dir=dir)

        @test ex2_poi.dim == ex2_poi_match.dim
        @test ex2_poi.valid == ex2_poi_match.valid
        @test ex2_poi.conv_section == ex2_poi_match.conv_section
        @test ex2_poi.cone_section == ex2_poi_match.cone_section
    end
end

end

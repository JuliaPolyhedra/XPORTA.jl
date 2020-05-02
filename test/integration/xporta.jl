using Test, PORTA

@testset "src/xporta.jl" begin

dir = "./test/files/"

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
        ieq1 = PORTA.read_ieq(ex1_poi_filepath*".ieq")
        match_ieq1 = PORTA.read_ieq(dir*"example1.ieq")
        @test ieq1.dim == match_ieq1.dim
        @test ieq1.inequalities == match_ieq1.inequalities
        @test ieq1.equalities == match_ieq1.equalities
        @test ieq1.lower_bounds == match_ieq1.lower_bounds
        @test ieq1.upper_bounds == match_ieq1.upper_bounds
        @test ieq1.elimination_order == match_ieq1.elimination_order
        @test ieq1.valid == match_ieq1.valid

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
        @test poi2.valid == poi2_match.valid

        PORTA.cleanup_porta_tmp(dir=dir)
    end
end

end

using Test, LinearAlgebra, XPORTA

@testset "./test/regression/simplex.jl" begin

dir = "./test/files/"

test_cases = [
    (POI(vertices=Matrix(1I, 1,1)), IEQ(equalities=[1//1 1//1], valid=reshape([1//1],(1,1)))),
    (POI(vertices=Matrix(1I, 2,2)), IEQ(equalities=[1//1 1//1 1//1], inequalities=[0 -1 0;0 1 1], valid=[0 1//1])),
    (POI(vertices=Matrix(1I, 3,3)), IEQ(equalities=[1//1 1//1 1//1 1//1], inequalities=[0 -1 0 0;0 0 -1 0;0 1 1 1], valid=[0 0 1//1])),
    (
        POI(vertices=Matrix(1I, 4,4)),
        IEQ(equalities=[1//1 1//1 1//1 1//1 1//1], inequalities=[0 -1 0 0 0;0 0 -1 0 0;0 0 0 -1 0;0 1 1 1 1], valid=[0 0 0 1//1]),
    ),
    (
        POI(vertices=Matrix(1I, 5,5)),
        IEQ(
            equalities=[1//1 1//1 1//1 1//1 1//1 1//1],
            inequalities=[0 -1 0 0 0 0;0 0 -1 0 0 0;0 0 0 -1 0 0;0 0 0 0 -1 0;0 1 1 1 1 1],
            valid=[0 0 0 0 1//1]),
    ),
    (
        POI(vertices=Matrix(1I, 6,6)),
        IEQ(
            equalities=[1//1 1//1 1//1 1//1 1//1 1//1 1//1],
            inequalities=[0 -1 0 0 0 0 0;0 0 -1 0 0 0 0;0 0 0 -1 0 0 0;0 0 0 0 -1 0 0;0 0 0 0 0 -1 0;0 1 1 1 1 1 1],
            valid=[0 0 0 0 0 1//1]),
    ),
    (
        POI(vertices=Matrix(1I, 7,7)),
        IEQ(
            equalities=[1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1],
            inequalities=[
                0 -1 0 0 0 0 0 0; 0 0 -1 0 0 0 0 0; 0 0 0 -1 0 0 0 0; 0 0 0 0 -1 0 0 0;
                0 0 0 0 0 -1 0 0; 0 0 0 0 0 0 -1 0; 0 1 1 1 1 1 1 1
            ],
            valid=[0 0 0 0 0 0 1//1]),
    ),
    (
        POI(vertices=Matrix(1I, 8,8)),
        IEQ(
            equalities=[1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1],
            inequalities=[
                0 -1 0 0 0 0 0 0 0; 0 0 -1 0 0 0 0 0 0; 0 0 0 -1 0 0 0 0 0; 0 0 0 0 -1 0 0 0 0;
                0 0 0 0 0 -1 0 0 0; 0 0 0 0 0 0 -1 0 0; 0 0 0 0 0 0 0 -1 0; 0 1 1 1 1 1 1 1 1
            ],
            valid=[0 0 0 0 0 0 0 1//1]),
    ),
    (
        POI(vertices=Matrix(1I, 9,9)),
        IEQ(
            equalities=[1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1],
            inequalities=[
                0 -1 0 0 0 0 0 0 0 0; 0 0 -1 0 0 0 0 0 0 0; 0 0 0 -1 0 0 0 0 0 0;
                0 0 0 0 -1 0 0 0 0 0; 0 0 0 0 0 -1 0 0 0 0; 0 0 0 0 0 0 -1 0 0 0;
                0 0 0 0 0 0 0 -1 0 0; 0 0 0 0 0 0 0 0 -1 0; 0 1 1 1 1 1 1 1 1 1
            ],
            valid=[0 0 0 0 0 0 0 0 1//1]),
    ),
    (
        POI(vertices=Matrix(1I, 10,10)),
        IEQ(
            equalities=[1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1 1//1],
            inequalities=[
                0 -1 0 0 0 0 0 0 0 0 0; 0 0 -1 0 0 0 0 0 0 0 0; 0 0 0 -1 0 0 0 0 0 0 0;
                0 0 0 0 -1 0 0 0 0 0 0; 0 0 0 0 0 -1 0 0 0 0 0; 0 0 0 0 0 0 -1 0 0 0 0;
                0 0 0 0 0 0 0 -1 0 0 0; 0 0 0 0 0 0 0 0 -1 0 0; 0 0 0 0 0 0 0 0 0 -1 0;
                0 1 1 1 1 1 1 1 1 1 1
            ],
            valid=[0 0 0 0 0 0 0 0 0 1//1]),
    ),
]

@testset "simplex dim=$id" for id in 1:length(test_cases)
    test_poi = test_cases[id][1]
    test_ieq = test_cases[id][2]

    # testing poi -> ieq
    ieq = traf(test_poi, dir=dir, filename="simplex_regression_test_$id")

    @test ieq.inequalities == test_ieq.inequalities
    @test ieq.equalities == test_ieq.equalities
    @test ieq.valid == test_ieq.valid
    @test ieq.dim == id

    @test length(ieq.lower_bounds) == 0
    @test length(ieq.upper_bounds) == 0
    @test length(ieq.elimination_order) == 0

    # testing ieq -> poi
    poi = traf(test_ieq, dir=dir, filename="simplex_regression_test_$id")

    @test poi.dim == id
    @test issetequal(poi.conv_section, test_poi.conv_section)

    @test length(poi.cone_section) == 0
    @test length(poi.valid) == 0
end

end

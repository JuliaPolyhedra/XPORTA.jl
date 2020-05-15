using Test, PORTA

@testset "./test/regression/clauser_horne_shimony_holt_polytope.jl" begin

dir = "./test/files/"

# The Clauser Horne Shimony Holt (CHSH) inequality is an important result in quantum
# information science. The CHSH inequality bounds the correlations in a bipartite
# dichotomic classical system. The classical correlations are represented by a
# polytope where each vertex denotes a deterministic outcome.
@testset "CHSH polytope" begin

    chsh_poi = POI(vertices=[
        -1 -1 -1 -1  1  1  1  1;
        -1 -1 -1  1  1 -1  1 -1;
        -1 -1  1 -1 -1  1 -1  1;
        -1 -1  1  1 -1 -1 -1 -1;
        -1  1 -1 -1  1  1 -1 -1;
        -1  1 -1  1  1 -1 -1  1;
        -1  1  1 -1 -1  1  1 -1;
        -1  1  1  1 -1 -1  1  1;
         1 -1 -1 -1 -1 -1  1  1;
         1 -1 -1  1 -1  1  1 -1;
         1 -1  1 -1  1 -1 -1  1;
         1 -1  1  1  1  1 -1 -1;
         1  1 -1 -1 -1 -1 -1 -1;
         1  1 -1  1 -1  1 -1  1;
         1  1  1 -1  1 -1  1 -1;
         1  1  1  1  1  1  1  1;
    ])

    chsh_ieq = traf(chsh_poi, dir=dir, filename="chsh_test")

    @test chsh_ieq.dim == 8
    @test chsh_ieq.valid == [1 1 1 1 1 1 1 1]

    @test chsh_ieq.inequalities == [
        -1 0 0 1 0 1 0 0 1;
        -1 0 1 0 1 0 0 0 1;
        0 -1 0 1 0 0 0 1 1;
        0 -1 1 0 0 0 1 0 1;
        0 1 -1 0 0 0 1 0 1;
        0 1 0 -1 0 0 0 1 1;
        0 1 0 1 0 0 0 -1 1;
        0 1 1 0 0 0 -1 0 1;
        1 0 -1 0 1 0 0 0 1;
        1 0 0 -1 0 1 0 0 1;
        1 0 0 1 0 -1 0 0 1;
        1 0 1 0 -1 0 0 0 1;
        -1 0 -1 0 -1 0 0 0 1;
        -1 0 0 -1 0 -1 0 0 1;
        0 -1 -1 0 0 0 -1 0 1;
        0 -1 0 -1 0 0 0 -1 1;
        0 0 0 0 -1 1 1 1 2;
        0 0 0 0 1 -1 1 1 2;
        0 0 0 0 1 1 -1 1 2;
        0 0 0 0 1 1 1 -1 2;
        0 0 0 0 -1 -1 -1 1 2;
        0 0 0 0 -1 -1 1 -1 2;
        0 0 0 0 -1 1 -1 -1 2;
        0 0 0 0 1 -1 -1 -1 2
    ]

    @test length(chsh_ieq.equalities) == 0
    @test length(chsh_ieq.upper_bounds) == 0
    @test length(chsh_ieq.lower_bounds) == 0
    @test length(chsh_ieq.elimination_order) == 0
end


# The Clauser Horne (CH) inequality is the same as the CHSH inequality except this
# the polytope is generated from the coditional probabilities of outcomes rather than
# the correlations between outcomes.
@testset "CH polytope" begin
    ch_poi = POI(vertices=[
        0 0 0 0 0 0 0 0;
        0 0 0 1 0 0 0 0;
        0 0 1 0 0 0 0 0;
        0 0 1 1 0 0 0 0;
        0 1 0 0 0 0 0 0;
        0 1 0 1 0 0 0 1;
        0 1 1 0 0 0 1 0;
        0 1 1 1 0 0 1 1;
        1 0 0 0 0 0 0 0;
        1 0 0 1 0 1 0 0;
        1 0 1 0 1 0 0 0;
        1 0 1 1 1 1 0 0;
        1 1 0 0 0 0 0 0;
        1 1 0 1 0 1 0 1;
        1 1 1 0 1 0 1 0;
        1 1 1 1 1 1 1 1;
    ])

    ch_ieq = traf(ch_poi, dir=dir, filename="ch_test")


    @test ch_ieq.dim == 8
    @test ch_ieq.valid == [1 1 1 1 1 1 1 1]

    @test ch_ieq.inequalities == [
        0 0 0 0 -1 0 0 0 0;
        0 0 0 0 0 -1 0 0 0;
        0 0 0 0 0 0 -1 0 0;
        0 0 0 0 0 0 0 -1 0;
        -1 0 0 0 0 1 0 0 0;
        -1 0 0 0 1 0 0 0 0;
        0 -1 0 0 0 0 0 1 0;
        0 -1 0 0 0 0 1 0 0;
        0 0 -1 0 0 0 1 0 0;
        0 0 -1 0 1 0 0 0 0;
        0 0 0 -1 0 0 0 1 0;
        0 0 0 -1 0 1 0 0 0;
        -1 0 -1 0 1 1 1 -1 0;
        -1 0 0 -1 1 1 -1 1 0;
        0 -1 -1 0 1 -1 1 1 0;
        0 -1 0 -1 -1 1 1 1 0;
        0 1 0 1 0 0 0 -1 1;
        0 1 1 0 0 0 -1 0 1;
        1 0 0 1 0 -1 0 0 1;
        1 0 1 0 -1 0 0 0 1;
        0 1 0 1 1 -1 -1 -1 1;
        0 1 1 0 -1 1 -1 -1 1;
        1 0 0 1 -1 -1 1 -1 1;
        1 0 1 0 -1 -1 -1 1 1;
    ]

    @test length(ch_ieq.equalities) == 0
    @test length(ch_ieq.upper_bounds) == 0
    @test length(ch_ieq.lower_bounds) == 0
    @test length(ch_ieq.elimination_order) == 0
end

end

using GLPK
using Polyhedra
const polyhedra_test = joinpath(dirname(dirname(pathof(Polyhedra))), "test")

include(joinpath(polyhedra_test, "utils.jl"))
include(joinpath(polyhedra_test, "polyhedra.jl"))
lpsolver = tuple()

using XPORTA
@testset "Polyhedra tests" begin
    polyhedratest(
        XPORTA.Library(GLPK.Optimizer),
        [
            # FIXME ERROR: MethodError: no method matching similar_type(::Type{IEQ{Rational{Int64}}}, ::Int64, ::Type{Float64})
            "simplex",
            # TODO Need to investigate, I get
            # failed process: Process(`/home/blegat/.julia/artifacts/b0627bab322e166a7ea3c9aa777f00551e7c4fdd/bin/xporta -T ./porta_tmp/traf_tmp.ieq`, ProcessExited(1)) [1]
            "ex1", "infeasible", "nonfulldimensional", "sparserect", "permutahedron", "sparse", "recipe",
            # overflow
            "issue224"
        ]
    )
end

struct Library <: Polyhedra.Library
    solver
    function Library(solver=nothing)
        new(solver)
    end
end
Polyhedra.similar_library(::Library, ::Polyhedra.FullDim, ::Type{T}) where T<:Union{Integer,Rational} = Library()
Polyhedra.similar_library(::Library, d::Polyhedra.FullDim, ::Type{T}) where T = Polyhedra.default_library(d, T)

mutable struct Polyhedron <: Polyhedra.Polyhedron{Rational{Int}}
    hrep::Union{Nothing, IEQ{Rational{Int}}}
    hred::Polyhedra.Redundancy
    vrep::Union{Nothing, POI{Rational{Int}}}
    vred::Polyhedra.Redundancy
    solver
    function Polyhedron(h::Union{Nothing, IEQ{Rational{Int}}}, hred::Polyhedra.Redundancy, v::Union{Nothing, POI{Rational{Int}}}, vred::Polyhedra.Redundancy, solver)
        new(h, hred, v, vred, solver)
    end
end
Polyhedron(h::IEQ{Rational{Int}}, solver) = Polyhedron(h, Polyhedra.UNKNOWN_REDUNDANCY, nothing, Polyhedra.UNKNOWN_REDUNDANCY, solver)
Polyhedron(h::Polyhedra.HRepresentation, solver) = Polyhedron(convert(IEQ{Rational{Int}}, h), solver)
Polyhedron(v::POI{Rational{Int}}, solver) = Polyhedron(nothing, Polyhedra.UNKNOWN_REDUNDANCY, v, Polyhedra.UNKNOWN_REDUNDANCY, solver)
Polyhedron(v::Polyhedra.VRepresentation, solver) = Polyhedron(convert(POI{Rational{Int}}, v), solver)

Polyhedra.FullDim(p::Polyhedron) = Polyhedra.FullDim_rep(p.hrep, p.vrep)
Polyhedra.library(p::Polyhedron) = Library(p.solver)
Polyhedra.default_solver(p::Polyhedron; T=nothing) = p.solver
Polyhedra.supportssolver(::Type{<:Polyhedron}) = true

Polyhedra.hvectortype(::Union{Polyhedron, Type{Polyhedron}}) = Polyhedra.hvectortype(IEQ{Rational{Int}})
Polyhedra.vvectortype(::Union{Polyhedron, Type{Polyhedron}}) = Polyhedra.vvectortype(POI{Rational{Int}})
Polyhedra.similar_type(::Type{<:Polyhedron}, ::Polyhedra.FullDim, ::Type{Rational{Int}}) = Polyhedron
Polyhedra.similar_type(::Type{<:Polyhedron}, d::Polyhedra.FullDim, ::Type{T}) where T = Polyhedra.default_type(d, T)


# Implementation of Polyhedron's mandatory interface
function Polyhedron(d::Polyhedra.FullDim, hits::Polyhedra.HIt...; solver=nothing)
    Polyhedron(IEQ{Rational{Int}}(d, hits...), solver)
end
function Polyhedron(d::Polyhedra.FullDim, vits::Polyhedra.VIt...; solver=nothing)
    Polyhedron(POI{Rational{Int}}(d, vits...), solver)
end

Polyhedra.polyhedron(rep::Polyhedra.Representation, lib::Library) = Polyhedron(rep, lib.solver)

# We don't copy as we don't implement any mutable operation.
Base.copy(p::Polyhedron) = Polyhedron(p.hrep, p.hred, p.vrep, p.vred, p.solver)

Polyhedra.hredundancy(p::Polyhedron) = p.hred
Polyhedra.vredundancy(p::Polyhedron) = p.vred

Polyhedra.hrepiscomputed(p::Polyhedron) = p.hrep !== nothing
function Polyhedra.computehrep!(p::Polyhedron)
    p.hrep = traf(p.vrep)
    p.hred = Polyhedra.NO_REDUNDANCY
end
function Polyhedra.hrep(p::Polyhedron)
    if !Polyhedra.hrepiscomputed(p)
        Polyhedra.computehrep!(p)
    end
    return p.hrep
end
Polyhedra.vrepiscomputed(p::Polyhedron) = p.vrep !== nothing
function Polyhedra.computevrep!(p::Polyhedron)
    p.vrep = traf(p.hrep)
    p.vred = Polyhedra.NO_REDUNDANCY
end
function Polyhedra.vrep(p::Polyhedron)
    if !Polyhedra.vrepiscomputed(p)
        Polyhedra.computevrep!(p)
    end
    return p.vrep
end

function Polyhedra.sethrep!(p::Polyhedron, h::Polyhedra.HRepresentation, redundancy = UNKNOWN_REDUNDANCY)
    p.hrep = h
    p.hred = redundancy
end
function Polyhedra.setvrep!(p::Polyhedron, v::Polyhedra.VRepresentation, redundancy = UNKNOWN_REDUNDANCY)
    p.vrep = v
    p.vred = redundancy
end
function Polyhedra.resethrep!(p::Polyhedron, h::Polyhedra.HRepresentation, redundancy = UNKNOWN_REDUNDANCY)
    p.hrep = h
    p.hred = redundancy
    p.vrep = nothing
    p.vred = Polyhedra.UNKNOWN_REDUNDANCY
end
function Polyhedra.resetvrep!(p::Polyhedron, v::Polyhedra.VRepresentation, redundancy = UNKNOWN_REDUNDANCY)
    p.vrep = v
    p.vred = redundancy
    p.hrep = nothing
    p.hred = Polyhedra.UNKNOWN_REDUNDANCY
end

@_norepelem Polyhedron Line

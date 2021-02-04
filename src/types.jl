"""
PORTA is a rational solver, its methods accept integer or rational valued matrices.
`PortaMatrix` describes the union of these types to simplify notation.

    PortaMatrix = Union{Matrix{Int}, Matrix{Rational{Int}}}
"""
PortaMatrix = Union{Matrix{Int}, Matrix{Rational{Int}}}

macro _norepelem(rep, elem)
    idxs = Symbol(string(elem) * "Indices")
    idx = Symbol(string(elem) * "Index")
    quote
        Base.length(idxs::Polyhedra.$idxs{T, <:$rep}) where {T} = 0
        Base.isempty(idxs::Polyhedra.$idxs{T, <:$rep}) where {T} = true
        Base.iterate(idxs::Polyhedra.$idxs{T, <:$rep}) where {T} = nothing
    end
end

macro norepelem(rep, elem)
    idxs = Symbol(string(elem) * "Indices")
    idx = Symbol(string(elem) * "Index")
    quote
        Base.length(idxs::Polyhedra.$idxs{T, <:$rep{T}}) where {T} = 0
        Base.isempty(idxs::Polyhedra.$idxs{T, <:$rep{T}}) where {T} = true
        Base.iterate(idxs::Polyhedra.$idxs{T, <:$rep{T}}) where {T} = nothing
    end
end


"""
The representation `rep` contain the elements `elem` inside a vector in the field `field`.
"""
macro matrepelem(rep, elem, field)
    idxs = Symbol(string(elem) * "Indices")
    idx = Symbol(string(elem) * "Index")
    esc(quote
        Base.length(idxs::Polyhedra.$idxs{T, <:$rep{T}}) where {T} = size(idxs.rep.$field, 1)
        Base.isempty(idxs::Polyhedra.$idxs{T, <:$rep{T}}) where {T} = isempty(idxs.rep.$field)
        function Polyhedra.startindex(idxs::Polyhedra.$idxs{T, <:$rep{T}}) where {T}
            if isempty(idxs.rep.$field)
                return nothing
            else
                return eltype(idxs)(1)
            end
        end
        #Base.get(rep::$rep{T}, idx::$idx{T}) where {T} = rep.$field[idx.value, :]
        function Polyhedra.nextindex(rep::$rep{T}, idx::Polyhedra.$idx{T}) where {T}
            if idx.value >= size(rep.$field, 1)
                return nothing
            else
                return typeof(idx)(idx.value + 1)
            end
        end
    end)
end


"""
The vertex representation of a polyhedron. This struct is analogous to PORTA files
with the `.poi` extension. Please refer to the [PORTA General File Format docs](https://github.com/bdoolittle/julia-porta/blob/master/README.md#general-file-format)
for more information regarding the `.poi` file format.

Constructor arguments are *optional*.

    POI(;
        vertices::PortaMatrix,
        rays::PortaMatrix,
        valid::PortaMatrix
    )

The `POI` struct can be initialized with either `Rational{Int}` or `Int` valued matrices.
On construction, all matrix values are standardized. By default matrix elements are
`Int`, if one field has `Rational{Int}` values then the entire `POI` struct will be
converted to type `Rational{Int}`.

Fields:
* `conv_section` - each matrix row is a vertex.
* `cone_section` - each matrix row is a ray.
* `valid` -  a feasible point for the vertex representation. In the context of a `POI`,
        this field has no known use.
* `dim` - the dimension of vertices and rays. This field is auto-populated on construction.

A `DomainError` is thrown if the column dimension of rays and vertices is not equal.
"""
struct POI{T} <: Polyhedra.VRepresentation{T}
    conv_section :: Matrix{T} # Collection of vertices
    cone_section :: Matrix{T} # Collection of Rays
    valid :: Matrix{T}
    dim :: Int
    function POI(;
        vertices::PortaMatrix = Array{Int}(undef,0,0),
        rays::PortaMatrix = Array{Int}(undef,0,0),
        valid::PortaMatrix = Array{Int}(undef,0,0)
    )
        args = [vertices, rays, valid]

        dims = map(arg -> size(arg)[2], args)
        max_dim = max(dims...) # should be equal except in case where one is null.

        if !all(dim -> (dim == max_dim) || (dim == 0), dims)
            throw(DomainError(dims, ": (dim_vertices, dim_rays, dim_valid), num_columns for vertices and rays must be equal."))
        end

        # standardizing type across POI struct
        poi_type = Int
        poi_args = args
        if !all(arg -> eltype(arg) <: Int, poi_args)
            poi_type = Rational{Int}
            poi_args = map( arg -> convert.(Rational{Int}, arg), args)
        end

        new{poi_type}(poi_args..., max_dim)
    end
end

@norepelem POI Line

@matrepelem POI Point conv_section
function Base.get(rep::POI{T}, idx::Polyhedra.PointIndex{T}) where T
    return rep.conv_section[idx.value, :]
end

@matrepelem POI Ray cone_section
function Base.get(rep::POI{T}, idx::Polyhedra.RayIndex{T}) where T
    return Polyhedra.Ray(rep.cone_section[idx.value, :])
end

function vmatrix!(matrix, elements, offset)
    for el in elements
        offset += 1
        matrix[offset, :] = Polyhedra.coord(el)
    end
    return offset
end

function POI{T}(D::Polyhedra.FullDim, vits::Polyhedra.VIt{T}...) where {T}
    points, lines, rays = Polyhedra.fillvits(D, vits...)
    d = Polyhedra.fulldim(D)
    conv = Matrix{T}(undef, length(points), d)
    vmatrix!(conv, points, 0)
    cone = Matrix{T}(undef, 2length(lines) + length(rays), d)
    offset = 0
    for el in lines
        offset += 1
        cone[offset, :] = Polyhedra.coord(el)
        offset += 1
        cone[offset, :] = -Polyhedra.coord(el)
    end
    offset = vmatrix!(cone, rays, 2length(lines))
    @assert offset == size(cone, 1)
    return POI(
        vertices = conv,
        rays = cone,
    )
end

@doc raw"""
The intersecting halfspace representation of a polyhedron. This struct is analogous
to PORTA files with the `.ieq` extension. Please refer to the [PORTA General File Format docs](https://github.com/bdoolittle/julia-porta/blob/master/README.md#general-file-format)
for more information refarding the `.ieq` file format.

Constructor arguments are *optional*.

    IEQ(;
        inequalities :: PortaMatrix,
        equalities :: PortaMatrix,
        lower_bounds :: Matrix{Int},
        upper_bounds :: Matrix{Int},
        elimination_order :: Matrix{Int},
        valid :: PortaMatrix
    )

The `IEQ` struct can be initialized with either `Rational{Int}` or `Int` valued matrices.
On construction, all matrix values are standardized. By default matrix elements are
`Int`, if one field has `Rational{Int}` values then the entire `IEQ` struct will be
converted to type `Rational{Int}`.

Constructor arguments `inequalities` and `equalities` each represent a linear system
of the following form.

```math
\begin{bmatrix}
\alpha_{1,1} & \dots & \alpha_{1,M} \\ \vdots & \ddots & \vdots \\ \alpha_{N,1} & \dots & \alpha_{N,M}
\end{bmatrix}\begin{bmatrix}
x_1 \\ \vdots \\ x_N
\end{bmatrix} \leq \text{ or } =
\begin{bmatrix} \beta_1 \\ \vdots \\ \beta_N \end{bmatrix}
```

Each matrix row represents a separate linear in/equality. The right-hand-side of
each in/equality is described by a  vector ``\vec{\alpha}_i`` with length ``M`` and
the right-hand-side is described with a single value ``\beta_i``, where ``i\in{1,...,N}``.

In the `.ieq` format, columnn vector ``\vec{\beta}`` is concatenated to the right
side of the ``\alpha`` matrix. In the `IEQ` struct, `inequalities` and `equalities`
both have the following form.

```math
\begin{bmatrix}
\alpha_{1,1} & \dots & \alpha_{1,M} & \beta_1 \\ \vdots & \ddots & \vdots & \vdots \\ \alpha_{N,1} & \dots & \alpha_{N,M} & \beta_N
\end{bmatrix}
```

`IEQ` Fields:
* `inequalities`: each matrix row is a linear inequality, the first M elements indexed `1:(end-1)` are α and the last element indexed `end` is β.
* `equalities`: each matrix row is linear equality, the first M elements indexed `1:(end-1)` are α and the last element indexed `end` is β.
* `lower_bounds`: a row vector which specifies the lower bound on each individual parameter. Used for enumerating integral points with `vint`.
* `upper_bounds`: a row vector which specifies the upper bound on each individual parameter. Used for enumerating integral points with `vint`.
* `valid`: a feasible point for the linear system.
* `dim`: the dimension of in/equalities, upper/lower bounds, etc. This field is auto-populated on construction.

A `DomainError` is thrown if the column dimension of fields is not equal.
"""
struct IEQ{T} <: Polyhedra.HRepresentation{T}
    valid :: Matrix{T}
    inequalities :: Matrix{T}
    equalities :: Matrix{T}
    lower_bounds :: Matrix{Int}
    upper_bounds :: Matrix{Int}
    elimination_order :: Matrix{Int}
    dim :: Int
    function IEQ(;
        inequalities::PortaMatrix = Array{Int}(undef,0,0),
        equalities::PortaMatrix = Array{Int}(undef,0,0),
        lower_bounds::Matrix{Int} = Array{Int}(undef,0,0),
        upper_bounds::Matrix{Int} =  Array{Int}(undef,0,0),
        elimination_order::Matrix{Int} =  Array{Int}(undef,0,0),
        valid::PortaMatrix = Array{Int}(undef,0,0)
    )
        # arguments may be converted to Rational
        eq_args = [inequalities, equalities]
        int_args = [lower_bounds, upper_bounds, elimination_order]

        # checking dimensions of inputs equality matrices have one extra column
        eq_dims = map(arg -> (size(arg)[2] == 0) ? 0 : size(arg)[2] - 1, eq_args)
        valid_dims = size(valid)[2]
        int_dims = map(arg -> size(arg)[2], int_args)
        max_dim = max(int_dims..., eq_dims..., valid_dims)
        if !all(dim -> (dim == max_dim) || (dim == 0), [eq_dims..., int_dims..., valid_dims])
            throw(DomainError(max_dim, "dimension mismatch. The number of columns in each argument should the same (or zero)."))
        end

        # standardizing type across IEQ struc
        ieq_type = Int
        rational_args = [valid, eq_args...]
        if !all(arg -> eltype(arg) <: Int, rational_args)
            ieq_type = Rational{Int}
            rational_args = map( arg -> convert.(Rational{Int}, arg), rational_args)
        end
        new{ieq_type}(rational_args..., int_args..., max_dim)
    end
end

function hmatrix(d::Polyhedra.FullDim, hs::Polyhedra.HIt{T}) where T
    A = Matrix{T}(undef, length(hs), Polyhedra.fulldim(d) + 1)
    for (i, h) in enumerate(hs)
        A[i, 1:(end-1)] = h.a
        A[i, end] = h.β
    end
    return A
end

function IEQ{T}(d::Polyhedra.FullDim, hyperplanes::Polyhedra.HyperPlaneIt{T}, halfspaces::Polyhedra.HalfSpaceIt{T}) where {T}
    return IEQ(
        equalities = hmatrix(d, hyperplanes),
        inequalities = hmatrix(d, halfspaces),
    )
end

@matrepelem IEQ HyperPlane equalities
function Base.get(rep::IEQ{T}, idx::Polyhedra.HyperPlaneIndex{T}) where T
    return Polyhedra.HyperPlane(rep.equalities[idx.value, 1:(end - 1)], rep.equalities[idx.value, end])
end

@matrepelem IEQ HalfSpace inequalities
function Base.get(rep::IEQ{T}, idx::Polyhedra.HalfSpaceIndex{T}) where T
    return Polyhedra.HalfSpace(rep.inequalities[idx.value, 1:(end - 1)], rep.inequalities[idx.value, end])
end

Polyhedra.FullDim(rep::Union{IEQ, POI}) = rep.dim
Polyhedra.vvectortype(::Type{POI{T}}) where {T} = Vector{T}
Polyhedra.hvectortype(::Type{IEQ{T}}) where {T} = Vector{T}
Polyhedra.coefficient_type(::Union{Type{POI{T}}, Type{IEQ{T}}}) where {T} = T

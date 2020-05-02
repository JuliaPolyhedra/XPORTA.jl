"""
Main module of `PORTA.jl`. This package provides an interface to the
[PORTA](http://porta.zib.de/) software. Exposed PORTA methods are named historically.

The compiled PORTA binaries are accessed through [`PORTA_jll.jl`](https://github.com/JuliaBinaryWrappers/PORTA_jll.jl)

**File I/O:** The compiled PORTA binaries read/write to files. By default the
directory `./porta_tmp` is used.
"""
module PORTA

# Module we are wrapping
using PORTA_jll

using Suppressor

# including local files
include("./file_io.jl")

"""
PORTA methods accept integer or rational valued matrices. The `PortaMatrix` type simplifies notation.

    PortaMatrix = Union{Matrix{Int}, Matrix{Rational{Int}}}
"""
PortaMatrix = Union{Matrix{Int}, Matrix{Rational{Int}}}

"""
The vertex representation of a polyhedron. This struct is analogous to PORTA files
with the `.poi` extension. Constructor arguments are *optional*.

    POI(;vertices::PortaMatrix, rays::PortaMatrix)

`POI` Fields:
* `conv_section`: each matrix row is a vertex.
* `cone_section`: each matrix row is a ray.
* `valid`:  a feasible point for the vertex representation.
* `dim`: `Int`, the dimension of vertices and rays. This field is auto-populated on construction.

A `DomainError` is thrown if the column dimension of rays and vertices is not equal.
"""
struct POI{T}
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

        if !all(map(dim -> (dim == max_dim) || (dim == 0), dims))
            throw(DomainError(dims, ": (dim_vertices, dim_rays, dim_valid), num_columns for vertices and rays must be equal."))
        end

        # standardizing type across POI struct
        poi_type = Int
        poi_args = args
        if !all(map( arg -> eltype(arg) <: Int, poi_args))
            poi_type = Rational{Int}
            poi_args = map( arg -> convert.(Rational{Int}, arg), args)
        end

        new{poi_type}(poi_args..., max_dim)
    end
end

@doc raw"""
The intersecting halfspaces representation of a polyhedron. This struct is analogous
to PORTA files with the `.ieq` extension. Constructor arguments are *optional*.

    IEQ(;
        inequalities :: PortaMatrix,
        equalities :: PortaMatrix,
        lower_bounds :: PortaMatrix,
        upper_bounds :: PortaMatrix,
        elimination_order :: PortaMatrix,
        valid :: PortaMatrix
    )

The `IEQ` struct can be initialized with either `Rational{Int}` or `Int` valued matrices.
On construction, all matrix values are standardized. By default matrix elements are
`Int`, if one field has `Rational{Int}` values then the entire `IEQ` struct will be
converted to type `Rational{Int}`.

Constructor arguments `inequalities` and `equalities` each represent a linear system
of the following form.

``
\begin{bmatrix}
\alpha_{1,1} & \dots & \alpha_{1,M} \\ \vdots & \ddots & \vdots \\ \alpha_{N,1} & \dots & \alpha_{N,M}
\end{bmatrix}
\leq \text{ or } =
\begin{bmatrix} \beta_1 \\ \vdots \\ \beta_N \end{bmatrix}
``

Each matrix row is populated by a vector ``\vec{\alpha}`` with length ``M`` denoting
the left hand side of the above equation. The right hand side of the in/equality,
``\beta_i``, is the last element of the `inequalities` and `equalities` matrices.
The resulting matrix has ``M+1`` columns to capture both ``\alpha`` and ``\beta``.

`IEQ` Fields:
* `inequalities`: each matrix row is a linear inequality, the first M elements indexed `1:(end-1)` are α ad the last element indexed `end` is β.
* `equalities`: each matrix row is linear equality, the first M elements indexed `1:(end-1)` are α ad the last element indexed `end` is β.
* `lower_bounds`: each matrix row is a lower bound for enumerating integral points with `vint`.
* `upper_bounds`: each matrix row is an upper bound for enumerating integral points with `vint`.
* `valid`: a feasible point for the linear system.
* `dim`: the dimension of in/equalities, upper/lower bounds, etc. This field is auto-populated on construction.

A `DomainError` is thrown if the column dimension of fields is not equal.
"""
struct IEQ{T}
    inequalities :: Matrix{T}
    equalities :: Matrix{T}
    lower_bounds :: Matrix{T}
    upper_bounds :: Matrix{T}
    elimination_order :: Matrix{T}
    valid :: Matrix{T}
    dim :: Int
    function IEQ(;
        inequalities::PortaMatrix = Array{Int}(undef,0,0),
        equalities::PortaMatrix = Array{Int}(undef,0,0),
        lower_bounds::PortaMatrix = Array{Int}(undef,0,0),
        upper_bounds::PortaMatrix =  Array{Int}(undef,0,0),
        elimination_order::PortaMatrix =  Array{Int}(undef,0,0),
        valid::PortaMatrix = Array{Int}(undef,0,0)
    )
        # arguments may be converted to Rational
        eq_args = [inequalities, equalities]
        point_args = [lower_bounds, upper_bounds, elimination_order, valid]

        # checking dimensions of inputs equality matrices have one extra column
        eq_dims = map(arg -> (size(arg)[2] == 0) ? 0 : size(arg)[2] - 1, eq_args)
        point_dims = map(arg -> size(arg)[2], point_args)
        max_dim = max(point_dims..., eq_dims...)
        if !all(map(dim -> (dim == max_dim) || (dim == 0), [eq_dims..., point_dims...]))
            throw(DomainError(max_dim, "dimension mismatch. The number of columns in each argument should the same (or zero)."))
        end

        # standardizing type across IEQ struc
        ieq_type = Int
        ieq_args = [eq_args..., point_args...]
        if !all(map( arg -> eltype(arg) <: Int, ieq_args))
            ieq_type = Rational{Int}
            ieq_args = map( arg -> convert.(Rational{Int}, arg), ieq_args)
        end

        new{ieq_type}(ieq_args..., max_dim)
    end
end

"""
    make_tmp_dir( dir::String = "./", tmp_dir::String = "porta_tmp") :: String

Creates the `tmp_dir` directory within `dir` and return the `tmp_dir` path. By
default, the created directory is `./porta_tmp`.
"""
function make_tmp_dir(;dir::String="./", tmp_dir::String="porta_tmp") :: String
    mkpath(dir*tmp_dir)
end

"""
    cleanup_porta_tmp( dir::String = "./")

Recursively removes `porta_tmp/` from directory `dir`.

!!! warning
    This method uses `rm("<dir/>porta_tmp/", force=true, recursive=true)`. Make
    sure not to delete important data.
"""
function cleanup_porta_tmp(;dir::String="./")
    rm(dir*"porta_tmp", force=true, recursive=true)
end

"""
    run_xporta( method_flag::String, args::String; suppress::Bool = true)

!!! warning
    This method is intended for advanced use of the xporta binaries. User knowledge
    of flags and arguments is required for successful execution.

Runs the xporta binary through `PORTA_jll`. The `method_flag` argument tells the xporta
binary which submethod to call. Valid options include:
* `"-D"` runs the `dim` method
* `"-F"` runs the `fmel` method
* `"-S"` runs the `portsort` method
* `"-T"` runs the `traf` method

The `args` parameter is uniquely specified by submethod, for more information
regarding methods see the [PORTA documentation](https://github.com/bdoolittle/julia-porta).
"""
function run_xporta(method_flag::String, args::String; suppress::Bool=true)
    if !(method_flag in ["-D", "-F", "-S", "-T"])
        throw(DomainError(method_flag, "method_flag is invalid. Valid options are \"-D\", \"-F\", \"-S\", \"-T\"."))
    end

    xporta() do xporta_path
        if suppress
            @suppress run(`$xporta_path $method_flag $args`)
        else
            run(`$xporta_path $method_flag $args`)
        end
    end
end

end # module

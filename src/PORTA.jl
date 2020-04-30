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

"""
    PortaMatrix = Union{Matrix{Int}, Matrix{Rational{Int}}}

PORTA methods accept integer or rational valued matrices. The `PortaMatrix` type simplifies notation.
"""
PortaMatrix = Union{Matrix{Int}, Matrix{Rational{Int}}}

"""
    POI(;vertices::PortaMatrix, rays::PortaMatrix)

`POI` Fields:
* `conv_section`: `Matrix{Int}` or `Matrix{Rational{Int}}`, each matrix row is a vertex.
* `cone_section`:  `Matrix{Int}` or `Matrix{Rational{Int}}`, each matrix row is a ray.
* `dim`: `Int`, the dimension of vertices and rays (rays and vertices must have the same number of columns).

A `DomainError` is thrown if the column dimension of rays and vertices is not equal.
"""
struct POI{T,S}
    conv_section :: Matrix{T} # Collection of vertices
    cone_section :: Matrix{S} # Collection of Rays
    dim :: Int
    function POI(;vertices::PortaMatrix=Array{Int}(undef, 0, 0), rays::PortaMatrix=Array{Int}(undef, 0, 0) )

        dim_vertices = size(vertices)[2]
        dim_rays =  size(rays)[2]
        dim = max(dim_vertices, dim_rays) # should be equal except in case where one is null.

        if (dim_vertices != 0) && (dim_rays != 0) && (dim_rays != dim_vertices)
            throw(DomainError((dim_vertices, dim_rays), ": (dim_vertices, dim_rays), num_columns for vertices and rays must be equal."))
        end

        new{eltype(vertices), eltype(rays)}(vertices, rays, dim)
    end
end


function read_poi(filepath :: String)::POI
    open(filepath) do file
        lines = readlines(file)

        # TODO: check if backslashes are used (set to rational if true)
        rational = false

        current_section = ""

        dim = 0

        # vertices and arrays will be accumulated
        conv_section_vertices = []
        cone_section_rays = []

        for line in lines

            # TODO: find the dimension
            # TODO: throw error if dimension is invalid


            # TODO: update section if needed (matches CONV_SECTION or CONE_SECTION)

            # TODO: if cone section check for rays  and push
            # TODO: if conv section check for vertices and push

            # TODO: if end break


        end

        # TODO: if vertices exist concat into matrix
        # TODO: if rays exist, concat into matrix

        # TODO: construct POI struct
        POI()
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
    cleanup_tmp_dir( dir::String = "./", tmp_dir::String = "porta_tmp" )

Recursively removes `tmp_dir` from directory `dir`.
"""
function cleanup_tmp_dir(;dir::String="./", tmp_dir::String="porta_tmp")
    rm(dir*tmp_dir, force=true, recursive=true)
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

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
The vertex representation of a polyhedra. This struct is analogous to PORTA files
with the `.poi` extensioon.

    POI(;vertices::PortaMatrix, rays::PortaMatrix)

The arguments to the constructor are *optional*

`POI` Fields:
* `conv_section`: `Matrix{Int}` or `Matrix{Rational{Int}}`, each matrix row is a vertex.
* `cone_section`: `Matrix{Int}` or `Matrix{Rational{Int}}`, each matrix row is a ray.
* `dim`: `Int`, the dimension of vertices and rays (rays and vertices must have the same number of column).

A `DomainError` is thrown if the column dimension of rays and vertices is not equal.
"""
struct POI{T,S}
    conv_section :: Matrix{T} # Collection of vertices
    cone_section :: Matrix{S} # Collection of Rays
    dim :: Int
    function POI(;vertices::PortaMatrix = Array{Int}(undef, 0, 0), rays::PortaMatrix = Array{Int}(undef, 0, 0) )

        dim_vertices = size(vertices)[2]
        dim_rays =  size(rays)[2]
        dim = max(dim_vertices, dim_rays) # should be equal except in case where one is null.

        if (dim_vertices != 0) && (dim_rays != 0) && (dim_rays != dim_vertices)
            throw(DomainError((dim_vertices, dim_rays), ": (dim_vertices, dim_rays), num_columns for vertices and rays must be equal."))
        end

        new{eltype(vertices), eltype(rays)}(vertices, rays, dim)
    end
end

"""
    read_poi(filepath :: String) :: POI{ Rational{Int64}, Rational{Int64} }

Creates a `POI` struct by parsing the provided `.poi` file. A `DomainError` is thrown
if argument `filepath` does not end with the `.poi` extension.
"""
function read_poi(filepath :: String)::POI{ Rational{Int64}, Rational{Int64} }
    if !(occursin(r"\.poi$", filepath))
        throw(DomainError(filepath, "filepath does not end in extension `.poi`."))
    end

    open(filepath) do file
        lines = readlines(file)

        # initializing mutable variables
        current_section = ""
        dim = 0

        # vertices and arrays will be accumulated
        conv_section_vertices = []
        cone_section_rays = []

        # reading file line by line
        for line in lines
            # .poi files are headed with DIM = <num_dimensions>
            dim_match = match(r"^DIM = (\d+)$",line)
            if dim_match != nothing
                dim = parse(Int64,dim_match.captures[1])
            end

            if occursin(r"CONV_SECTION", line)
                current_section = "CONV_SECTION"
            elseif occursin(r"CONE_SECTION", line)
                current_section = "CONE_SECTION"
            end

            # if line contains a vertex/ray
            if occursin(r"^(\(\s*\d+\))?(\s*\d+)+", line)
                digit_matches = collect(eachmatch(r"\s*(\d+)(?!\))(?:/(\d+))?", line))
                num_matches = length(digit_matches)

                # map makes col vectors reshape to be row vectors
                point = reshape( map(regex -> begin
                    num = parse(Int64, regex.captures[1])
                    den = (regex.captures[2] === nothing) ? 1 : parse(Int64, regex.captures[2])

                    Rational(num, den)
                end, digit_matches), (1,num_matches))

                if current_section == "CONV_SECTION"
                    push!(conv_section_vertices, point)
                elseif current_section == "CONE_SECTION"
                    push!(cone_section_rays, point)
                end
            end

            if occursin(r"END", line)
                break
            end
        end

        null_matrix = Array{Rational{Int64}}(undef, 0, 0)
        vertices = (length(conv_section_vertices) == 0) ? null_matrix : vcat(conv_section_vertices...)
        rays = (length(conv_section_vertices) == 0) ? null_matrix : vcat(cone_section_rays...)

        POI(vertices=vertices, rays=rays)
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

!!! warning
    This method uses `rm("dir/tmp_dir/", force=true, recursive=true)`. Make sure you
    aren't deleting important data.
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

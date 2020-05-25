"""
    run_valid(method_flag::String, args::Array{String,1}; verbose::Bool=false)

!!! warning
    This method is intended for advanced use of the `valid` binary. User knowledge
    of flags and arguments is required for successful execution. Users
    must explicitly handle file IO for the `valid` binary.

Runs the `valid` binary through `PORTA_jll`. The `method_flag` argument tells the `valid`
binary which subroutine to call. Valid options include:
* `"-C"` runs the `fctp` subroutine
* `"-I"` runs the `iespo` subroutine
* `"-P"` runs the `posie` subroutine
* `"-V"` runs the `vint` subroutine

The `args` parameter is uniquely specified by `method_flag`, for more information
regarding methods and arguments see the [valid documentation](https://github.com/bdoolittle/julia-porta#valid).

The `verbose` argument determines whether the `valid` binary prints to `STDOUT`.
"""
function run_valid(method_flag::String, args::Array{String,1}; verbose::Bool=false)
    if !(method_flag in ["-C", "-I", "-P", "-V"])
        throw(DomainError(method_flag, "method_flag is invalid. Valid options are \"-C\", \"-I\", \"-P\", \"-V\"."))
    end

    valid() do valid_path
        if verbose
            run(`$valid_path $method_flag $args`)
        else
            @suppress run(`$valid_path $method_flag $args`)
        end
    end
end


function fctp(inequalities::PortaMatrix, poi::POI; dir::String="./", filename::String="fctp_tmp", cleanup::Bool=true, verbose::Bool=false) :: Vector{POI{Rational{Int}}}

    workdir = cleanup ? make_porta_tmp(dir) : dir

    ieq_filepath = write_ieq(filename, IEQ(inequalities=inequalities), dir=workdir)
    poi_filepath = write_poi(filename, poi, dir=workdir)

    run_valid("-C", [ieq_filepath, poi_filepath], verbose=verbose)


    poi_files = filter(file -> occursin(r"^.*\.ieq\d+\.poi$", file), readdir(workdir))

    poi_array = Vector{POI{Rational{Int}}}(undef, length(poi_files))
    for file in poi_files
        println(file)

        poi_match = match(r"^.*\.ieq(\d+).poi$", file)

        id = parse(Int, poi_match.captures[1])

        poi_array[id] = read_poi(workdir * "/" * file)
   end

    if (cleanup)
        rm_porta_tmp(dir)
    end

    return poi_array
end

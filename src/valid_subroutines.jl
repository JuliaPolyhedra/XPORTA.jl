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

"""
    posie( ieq::IEQ, poi::POI; kwargs... ) :: POI{Rational{Int}}

Enumerates the points and rays in the `POI` which satisfy the linear system
of the `IEQ`. A `POI` containing the valid points and rays is returned.

`kwargs` is shorthand for the following keyword arguments:
* `dir :: String = "./"` - The directory to which files are written.
* `filename :: String = "traf_tmp"`- The name of produced files.
* `cleanup :: Bool = true` - If `true`, created files are removed after computation.
* `verbose :: Bool = false`- If `true`, PORTA will print progress to `STDOUT`.

For more details regarding `posie` please refer to the [PORTA posie documentation](https://github.com/bdoolittle/julia-porta#posie).
"""
function posie(ieq::IEQ, poi::POI;
    dir::String="./",
    filename::String="posie_tmp",
    cleanup::Bool=true,
    verbose::Bool=false
) :: POI{Rational{Int}}

    workdir = cleanup ? make_porta_tmp(dir) : dir

    ieq_filepath = write_ieq(filename, ieq, dir=workdir)
    poi_filepath = write_poi(filename, poi, dir=workdir)

    run_valid("-P", [ieq_filepath, poi_filepath], verbose=verbose)

    valid_poi = isfile(ieq_filepath * ".poi") ? read_poi(ieq_filepath * ".poi") : POI(vertices = Array{Rational{Int}}(undef,0,0))

    if (cleanup)
        rm_porta_tmp(dir)
    end

    return valid_poi
end

function iespo(ieq::IEQ, poi::POI;
    dir::String="./",
    filename::String="iespo_tmp",
    opt_flag::String="",
    cleanup::Bool=true,
    verbose::Bool=false
) :: IEQ{Rational{Int}}

    workdir = cleanup ? make_porta_tmp(dir) : dir

    valid_args = Array{String,1}(undef,0)
    if opt_flag != ""
        if opt_flag != "-v"
            throw(DomainError(opt_flag, "invalid `opt_flag` argument. The valid option is \"-v\"."))
        end
        push!(valid_args, opt_flag)
    end

    ieq_filepath = write_ieq(filename, ieq, dir=workdir)
    poi_filepath = write_poi(filename, poi, dir=workdir)
    push!(valid_args, ieq_filepath, poi_filepath)

    run_valid("-I", valid_args, verbose=verbose)

    valid_ieq = read_ieq(poi_filepath * ".ieq")

    if (cleanup)
        rm_porta_tmp(dir)
    end

    return valid_ieq
end

function fctp( inequalities::PortaMatrix, poi::POI;
    dir::String="./",
    filename::String="fctp_tmp",
    cleanup::Bool=true,
    verbose::Bool=false
) :: Dict{Int, POI{Rational{Int}}}

    workdir = cleanup ? make_porta_tmp(dir) : dir

    ieq_filepath = write_ieq(filename, IEQ(inequalities=inequalities), dir=workdir)
    poi_filepath = write_poi(filename, poi, dir=workdir)

    run_valid("-C", [ieq_filepath, poi_filepath], verbose=verbose)

    poi_files = filter(file -> occursin(r"^.*\.ieq\d+\.poi$", file), readdir(workdir))

    poi_tuples = Vector{Tuple{Int, POI{Rational{Int}}}}(undef, length(poi_files))
    for i in 1:length(poi_files)
        println(poi_files[i])

        poi_match = match(r"^.*\.ieq(\d+).poi$", poi_files[i])

        ineq_id = parse(Int, poi_match.captures[1])
        poi = read_poi(workdir * "/" * poi_files[i])

        poi_tuples[i] = (ineq_id, poi)
   end

    if (cleanup)
        rm_porta_tmp(dir)
    end

    Dict{Int, POI{Rational{Int}}}(poi_tuples)
end

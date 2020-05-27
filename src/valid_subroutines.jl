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

For more details regarding `posie()` please refer to the [PORTA posie documentation](https://github.com/bdoolittle/julia-porta#posie).
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

"""
    fctp( inequalities::PortaMatrix, poi::POI; kwargs... ) :: Dict{ String, Dict{Int, POI{Rational{Int}}} }

For the provided `inequalities`, determines which ones tightly bound the polytope
specified by the input `POI` and which inequalities are violated by the input `POI`.
Tight bounds are labeled `"valid"` and violations are labeled `"invalid"`. In each case
the points which saturate or violate the inequalities are returned in a poi. Inequalities
which are loose bounds are not returned.

Each row of the `inequalities` input corresponds to a distinct inequality in the
form specified by the `IEQ.inequalites` field.

The output has a nested dictionary structure:
```
Dict(
    "valid" => Dict(
        id => saturating_poi,  # points/rays which saturate inequalities[id]
        ...
    ),
    "invalid" => Dict(
        id => violating_poi,   # points/rays which violate inequalities[id]
        ...
    )
)
```

where `ineq_id` corresponds to the row index of the input `inequalities`. The `"valid"`
and `"invalid"` dictionaries may include zero or more elements.

`kwargs` is shorthand for the following keyword arguments:
* `dir::String = "./"` - The directory to which files are written.
* `filename::String = "traf_tmp"`- The name of produced files.
* `cleanup::Bool = true` - If `true`, created files are removed after computation.
* `verbose::Bool = false`- If `true`, PORTA will print progress to `STDOUT`.

For more details regarding `fctp()` please refer to the [PORTA fctp documentation](https://github.com/bdoolittle/julia-porta#fctp).
"""
function fctp( inequalities::PortaMatrix, poi::POI;
    dir::String="./",
    filename::String="fctp_tmp",
    cleanup::Bool=true,
    verbose::Bool=false
) :: Dict{ String, Dict{Int, POI{Rational{Int}}} }

    workdir = cleanup ? make_porta_tmp(dir) : dir

    ieq_filepath = write_ieq(filename, IEQ(inequalities=inequalities), dir=workdir)
    poi_filepath = write_poi(filename, poi, dir=workdir)

    run_valid("-C", [ieq_filepath, poi_filepath], verbose=verbose)

    poi_files = filter(file -> occursin(r"^.*\.ieq\d+\.poi$", file), readdir(workdir))

    tight_poi_tuples = Vector{Tuple{Int, POI{Rational{Int}}}}(undef, 0)
    invalid_poi_tuples = Vector{Tuple{Int, POI{Rational{Int}}}}(undef, 0)
    for i in 1:length(poi_files)

        poi_match = match(r"^.*\.ieq(\d+).poi$", poi_files[i])

        ineq_id = parse(Int, poi_match.captures[1])
        poi = read_poi(workdir * "/" * poi_files[i])

        poi_contains_points = (length(poi.conv_section) == 0) ? false : true
        poi_contains_rays = (length(poi.cone_section) == 0) ? false : true

        ineq = inequalities[ineq_id,:]

        # PORTA does not indicate which .poi files are valid or invalid. The
        # check is implemented manually below. A .poi is either valid or invalid
        # thus it is sufficient to check a single element.
        if poi_contains_points
            # A valid point must satisfy the inequality with equality.
            if ineq[1:end-1]' * poi.conv_section[1,:] == ineq[end]
                push!(tight_poi_tuples, (ineq_id, poi))
            else
                push!(invalid_poi_tuples, (ineq_id, poi))
            end
        elseif poi_contains_rays
            # A valid ray must make an obtuse angle with the normal vector of the
            # bounding halfspace.
            if ineq[1:end-1]' * poi.cone_section[1,:] <= 0
                push!(tight_poi_tuples, (ineq_id, poi))
            else
                push!(invalid_poi_tuples, (ineq_id, poi))
            end
        end
   end

    if (cleanup)
        rm_porta_tmp(dir)
    end

    tight_poi_dict = Dict{Int, POI{Rational{Int}}}(tight_poi_tuples)
    invalid_poi_dict = Dict{Int, POI{Rational{Int}}}(invalid_poi_tuples)

    Dict{String, Dict{Int, POI{Rational{Int}}}}(
        "valid" => tight_poi_dict,
        "invalid" => invalid_poi_dict
    )
end

"""
    iespo( ieq::IEQ, poi::POI; kwargs...) :: IEQ{Rational{Int}}

Enumerates the valid equations and inequalities of the `IEQ` which satisfy the
points and rays in the `POI`. An `IEQ` containing valid inequalities and equations
is returned.

!!! danger
    This method does not work as described by the [PORTA iespo documentation](https://github.com/bdoolittle/julia-porta#iespo). Invalid
    in/equalities are not filtered out. However, the strong validity check does
    work.

    To run the strong validity check, use arguments `cleanup=false` and `opt_flag="-v"`.
    With these arguments, `iespo()` will print a table to the output `.ieq` file which
    can manually be read/parsed.

    In a future update, a parser may be written for the strong validity table or
    the PORTA source code may be update to properly execute the in/equality filtering.

`kwargs` is shorthand for the following keyword arguments:
* `dir::String = "./"` - The directory to which files are written.
* `filename::String = "traf_tmp"`- The name of produced files.
* `strong_validity::Bool =  false` - Prints the strong validity table to the output `IEQ`, (requires manual parsing).
* `cleanup::Bool = true` - If `true`, created files are removed after computation.
* `verbose::Bool = false`- If `true`, PORTA will print progress to `STDOUT`.

For more details regarding `iespo()` please refer to the [PORTA iespo documentation](https://github.com/bdoolittle/julia-porta#iespo).
"""
function iespo(ieq::IEQ, poi::POI;
    dir::String="./",
    filename::String="iespo_tmp",
    strong_validity::Bool=false,
    cleanup::Bool=true,
    verbose::Bool=false
) :: IEQ{Rational{Int}}

    workdir = cleanup ? make_porta_tmp(dir) : dir

    valid_args = Array{String,1}(undef,0)
    if strong_validity
        push!(valid_args, "-v")
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

"""
    run_xporta( method_flag::String, args::Array{String,1}; verbose::Bool = false) :: String

!!! warning
    This method is intended for advanced use of the xporta binary. User knowledge
    of flags and arguments is required for successful execution. Furthermore, users
    must explicitly handle file IO for the `xporta` binary.

Runs the `xporta` binary through `PORTA_jll` and returns a string containing `STDOUT`.
The `method_flag` argument specifies which `xporta` subroutine to call.

Valid options for `method_flag` are:
* `"-D"` runs the `dim` subroutine
* `"-F"` runs the `fmel` subroutine
* `"-S"` runs the `portsort` subroutine
* `"-T"` runs the `traf` subroutine

The `args` parameter is uniquely specified by `method_flag`, for more information
regarding methods and arguments see the [`xporta` documentation](https://github.com/bdoolittle/julia-porta#xporta).

If `verbose=true` the `xporta` prints to `STDOUT`.
"""
function run_xporta(method_flag::String, args::Array{String,1}; verbose::Bool=false) :: String
    if !(method_flag in ["-D", "-F", "-S", "-T"])
        throw(DomainError(method_flag, "method_flag is invalid. Valid options are \"-D\", \"-F\", \"-S\", \"-T\"."))
    end

    stdout = xporta() do xporta_path
        @capture_out run(`$xporta_path $method_flag $args`)
    end

    if verbose
        print(stdout)
    end

    stdout
end

"""
The `traf` method computes an `IEQ` struct given a `POI` struct,

    traf( poi::POI; kwargs... ) :: IEQ{Rational{Int}}

or computes the `POI` struct from the `IEQ` struct.

    traf(ieq::IEQ; kwargs... ) :: POI{Rational{Int}}

When converting an `IEQ` -> `POI` the `valid` field of the `IEQ` must be populated
if the origin is not a feasible point of the linear system.

`kwargs` is shorthand for the following keyword arguments:

* `dir::String = "./"` - The directory in which to write files.
* `filename::String = "traf_tmp"`- The name of produced files.
* `cleanup::Bool = true` - If `true`, created files are removed after computation.
* `opt_flag::String = ""` - Optional flags to pass the `traf` method of the xporta binary.
* `verbose::Bool = false`- If `true`, PORTA will print progress to `STDOUT`.

The following excerpt from the PORTA documentation lists valid optional flags and their behavior:

        -p     Unbuffered redirection of terminal messages into  file filename_'.prt'

        -o     Use  a heuristic to eliminate that variable  next,  for which the number of new
               inequalities is minimal (local criterion). If this option is set, inequalities
               which are  recognized  to  be facet-inducing  for the finite linear system
               are printed into a  file as soon as they are identified.

        -c     Fourier-Motzkin elimination without using the rule  of Chernikov

        -s     Appends a statistical  part  to  each  line  with  the number  of coefficients

        -v     Printing a   table in the  output file which indicates strong validity

        -l     Use  a  special  integer arithmetic allowing the integers to have arbitrary
               lengths. This arithmetic is not as efficient as the system's integer
               arithmetic with respect to time and storage requirements.

               Note: Output values which exceed the 32-bit integer storage size
               are written in hexadecimal format (hex). Such hexadecimal format
               can not be reread as input.

For more details regarding `traf` please refer to the [PORTA traf documentation](https://github.com/bdoolittle/julia-porta#traf).
"""
function traf(poi::POI;
    dir::String="./",
    filename::String="traf_tmp",
    opt_flag::String="",
    cleanup::Bool=true,
    verbose::Bool=false
) :: IEQ{Rational{Int}}
    xporta_args = Array{String,1}(undef,0)
    if opt_flag != ""
        if !occursin(r"^-[poscvl]{1,6}$", opt_flag) || (length(opt_flag) != length(unique(opt_flag)))
            throw(DomainError(opt_flags, "invalid `opt_flag` argument. Valid options are any ordering of '-poscvl' and substrings."))
        end
        push!(xporta_args, opt_flag)
    end

    poi_dir = cleanup ? make_porta_tmp(dir) : dir

    file_path = write_poi(filename, poi, dir=poi_dir)
    push!(xporta_args, file_path)

    run_xporta("-T", xporta_args, verbose=verbose)

    ieq = read_ieq(file_path * ".ieq")

    if (cleanup)
        rm_porta_tmp(dir)
    end

    return ieq
end

function traf(ieq::IEQ;
    dir::String="./",
    filename::String="traf_tmp",
    opt_flag::String="",
    cleanup::Bool=true,
    verbose::Bool=false
) :: POI{Rational{Int}}
    xporta_args = Array{String,1}(undef,0)
    if opt_flag != ""
        if !occursin(r"^-[poscvl]{1,6}$", opt_flag) || (length(opt_flag) != length(unique(opt_flag)))
            throw(DomainError(opt_flags, "invalid `opt_flag` argument. Valid options are any ordering of '-poscvl' and permuted substrings."))
        end
    end

    ieq_dir = cleanup ? make_porta_tmp(dir) : dir

    file_path = write_ieq(filename, ieq, dir=ieq_dir)
    push!(xporta_args, file_path)

    run_xporta("-T", xporta_args, verbose=verbose)

    poi = read_poi(file_path * ".poi")

    if cleanup
        rm_porta_tmp(dir)
    end

    return poi
end

"""
    portsort( ieq::IEQ; kwargs... ) :: IEQ{Rational{Int}}

Sorts the inequalities and equalities of the provided `IEQ`.

    portsort( poi::POI; kwargs... ) :: POI{Rational{Int}}

Sorts the vertices and rays of the provided `POI`.

Sorting is performed in the following hierarchy:
1. Right-hand-side of in/equalities from high to low.
2. Scale factors from low to high.
3. Lexicographical order.

`kwargs` is shorthand for the keyword arguments:
* `dir::String = "./"` - The directory in which to write files.
* `filename::String = "portsort_tmp"`- The name of produced files.
* `cleanup::Bool = true` - If `true`, created files are removed after computation.
* `verbose::Bool = false`- If `true`, PORTA will print progress to `STDOUT`.

For more details regarding `portsort` please refer to the [PORTA portsort documentation](https://github.com/bdoolittle/julia-porta#portsort).
"""
function portsort(ieq::IEQ;
    dir::String="./",
    filename::String="portsort_tmp",
    cleanup::Bool=true,
    verbose::Bool=false
) :: IEQ{Rational{Int}}

    workdir = cleanup ? make_porta_tmp(dir) : dir

    ieq_filepath = write_ieq(filename, ieq, dir=workdir)

    run_xporta("-S", [ieq_filepath], verbose=verbose)

    ieq = read_ieq(ieq_filepath * ".ieq")

    if cleanup
        rm_porta_tmp(dir)
    end

    return ieq
end

function portsort(poi::POI;
    dir::String="./",
    filename::String="portsort_tmp",
    cleanup::Bool=true,
    verbose::Bool=false
) :: POI{Rational{Int}}

    workdir = cleanup ? make_porta_tmp(dir) : dir

    poi_filepath = write_poi(filename, poi, dir=workdir)

    run_xporta("-S", [poi_filepath], verbose=verbose)

    poi = read_poi(poi_filepath * ".poi")

    if cleanup
        rm_porta_tmp(dir)
    end

    return poi
end

"""
    dim( poi::POI; kwargs... ) :: Dict{String, Union{ Int, IEQ{Rational{Int}} } }

Given a `POI` computes the minimal dimension and constraining equalities for the
convex hull of the `POI`. The returned dictionary has the form

```
Dict(
    "dim" => <integer number of dimensions>,
    "ieq" => <IEQ struct w/ constraining equalities>
)
```

`kwargs` specifies keyword args:
* `dir::String = "./"` - The directory in which to write files.
* `filename::String = "dim_tmp"`- The name of produced files.
* `cleanup::Bool = true` - If `true`, created files are removed after computation.
* `verbose::Bool = false`- If `true`, PORTA will print progress to `STDOUT`.

For more details regarding `dim` please refer to the [PORTA dim documentation](https://github.com/bdoolittle/julia-porta#dim).
"""
function dim(poi::POI;
    dir::String="./",
    filename::String="dim_tmp",
    cleanup::Bool=true,
    verbose::Bool=false
) :: Dict{String, Union{Int, IEQ{Rational{Int}}}}

    workdir = cleanup ? make_porta_tmp(dir) : dir

    poi_filepath = write_poi(filename, poi, dir=workdir)

    stdout = run_xporta("-D", [poi_filepath], verbose=verbose)

    dim_match = match(r"DIMENSION OF THE POLYHEDRON : (\d+)", stdout)

    eq_matches = collect(eachmatch(r"\(\s*\d+\)(.*)==\s*(.*)\n", stdout))

    num_eq = length(eq_matches)

    equations = zeros(Rational{Int}, (num_eq, poi.dim + 1))
    for i in 1:num_eq
        eq_match = eq_matches[i]

        # parse left hand side matches
        for lhs_match in eachmatch(r"\s*([+-])\s*(?:(\d+)(?:/(\d+))?)?x(\d+)", eq_match.captures[1])

            sign = lhs_match.captures[1]
            num = (lhs_match.captures[2] === nothing) ? parse(Int, sign*"1") : parse(Int, sign*lhs_match.captures[2])
            den = (lhs_match.captures[3] === nothing) ? 1 : parse(Int, lhs_match.captures[3])
            col_id = parse(Int, lhs_match.captures[4])

            equations[i,col_id] += Rational(num, den)
        end

        # parse right hand side match
        rhs_match = match(r"([+-])?\s*(\d+)(?:/(\d+))?", eq_match.captures[2])

        sign = (rhs_match.captures[1] === nothing) ? "+" : rhs_match.captures[1]
        num = parse(Int, sign*rhs_match.captures[2])
        den = (rhs_match.captures[3] === nothing) ? 1 : parse(Int, rhs_match.captures[3])

        equations[i,end] += Rational(num, den)
    end

    if cleanup
        rm_porta_tmp(dir)
    end

    Dict(
        "dim" => parse(Int, dim_match.captures[1]),
        "ieq" => IEQ(equalities = equations)
    )
end

"""
    fmel( ieq::IEQ; kwargs... ) :: IEQ{Rational{Int}}

Projects the linear system of `IEQ` onto a subspace using fourier-motzkin elimination.
The projected linear system is returned in an `IEQ`. Note that redundant inequalities
may be present in the returned `IEQ`.

The `elimination_order` field of the `IEQ` must be populated and of length `dim`.
A `0` value indicates a parameter which will not be eliminated and `1,2,...` specifies
the order in which the parameters will be eliminated. Performance may change based
on the order of elimination.

`kwargs` specifies keyword args:
* `dir::String = "./"` - The directory in which to write files.
* `filename::String = "fmel_tmp"`- The name of produced files.
* `opt_flag::String = ""` - optional flags for the `fmel` subroutine.
* `cleanup::Bool = true` - If `true`, created files are removed after computation.
* `verbose::Bool = false`- If `true`, PORTA will print progress to `STDOUT`.

A `DomainError` is thrown if the `elimination_order` field is not of length `dim`.
A `DomainError` is thrown if the `opt_flag` argument is not a substring of `"-pcl"`
or its permutations.

The valid options for the `opt_flag`:
```
-p    Unbuffered redirection of the terminal messages into the file
      input_fname_with_suffix_'prt'

-c    Generation of new inequalities without the rule of Chernikov.

-l    Use  a  special  integer arithmetic allowing the integers to have arbitrary
      lengths.  This arithmetic is not as efficient as the system's integer
      arithmetic with respect to time and storage requirements.

      Note: Output values which exceed the 32-bit integer storage  size  are written
      in hexadecimal format (hex). Such hexadecimal format can not be reread as input.
```

For more details regarding `fmel` please refer to the [PORTA fmel documentation](https://github.com/bdoolittle/julia-porta#fmel).
"""
function fmel(ieq::IEQ;
    dir::String="./",
    filename::String="fmel_tmp",
    opt_flag::String="",
    cleanup::Bool=true,
    verbose::Bool=false
) :: IEQ{Rational{Int}}

    workdir = cleanup ? make_porta_tmp(dir) : dir

    if length(ieq.elimination_order) != ieq.dim
        throw(DomainError(ieq.elimination_order, "elimination_order field is required for `fmel` and there should be a single row."))
    end

    xporta_args = Array{String,1}(undef,0)
    if opt_flag != ""
        if !occursin(r"^-[pcl]{1,3}$", opt_flag) || (length(opt_flag) != length(unique(opt_flag)))
            throw(DomainError(opt_flags, "invalid `opt_flag` argument. Valid options are any ordering of '-pcl' and substrings."))
        end
        push!(xporta_args, opt_flag)
    end

    ieq_filepath = write_ieq(filename, ieq, dir=workdir)
    push!(xporta_args, ieq_filepath)

    run_xporta("-F", xporta_args, verbose=verbose)

    ieq = read_ieq(ieq_filepath * ".ieq")

    if cleanup
        rm_porta_tmp(dir)
    end

    return ieq
end

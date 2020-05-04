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
function run_xporta(method_flag::String, args::Array{String,1}; suppress::Bool=true)
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

"""
"""
function traf(poi::POI; dir::String="./", filename::String="traf_tmp", opt_flag::String="", cleanup::Bool=true) :: IEQ
    xporta_args = Array{String,1}(undef,0)
    if opt_flag != ""
        if !occursin(r"^-[poscvl]{1,6}$", opt_flag) || (length(opt_flag) != length(unique(opt_flag)))
            throw(DomainError(opt_flags, "invalid opt_flags argument. Valid options any ordering of '-poscvl' and substrings."))
        end
        push!(xporta_args, opt_flag)
    end

    poi_dir = cleanup ? make_porta_tmp(dir) : dir

    file_path = write_poi(filename, poi, dir=poi_dir)
    push!(xporta_args, file_path)

    run_xporta("-T", xporta_args)

    ieq = read_ieq(file_path * ".ieq")

    if (cleanup)
        rm_porta_tmp(dir)
    end

    return ieq
end

function traf(ieq::IEQ; dir::String="./", filename::String="traf_tmp", opt_flag::String="", cleanup::Bool=true) :: POI
    xporta_args = Array{String,1}(undef,0)
    if opt_flag != ""
        if !occursin(r"^-[poscvl]{1,6}$", opt_flag) || (length(opt_flag) != length(unique(opt_flag)))
            throw(DomainError(opt_flags, "invalid opt_flags argument. Valid options any ordering of '-poscvl' and substrings."))
        end
    end

    ieq_dir = cleanup ? make_porta_tmp(dir) : dir

    file_path = write_ieq(filename, ieq, dir=ieq_dir)
    push!(xporta_args, file_path)

    run_xporta("-T", xporta_args)

    poi = read_poi(file_path * ".poi")

    if (cleanup)
        rm_porta_tmp(dir)
    end

    return poi
end

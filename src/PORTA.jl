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

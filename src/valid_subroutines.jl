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
            @suppress run(`$xporta_path $method_flag $args`)
        end
    end
end

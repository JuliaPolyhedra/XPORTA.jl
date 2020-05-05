"""
The main module of `PORTA.jl`. This package provides an interface to the
[PORTA](http://porta.zib.de/) software. Exported types and methods are named
historically after the PORTA source code.

# Exports

- [`POI`](@ref) - type, The vertex representation of a polyhedra.
- [`IEQ`](@ref) - type, The intersecting halfspace representation of a polyhedra.
- [`traf`](@ref) - method, Converts a `POI` -> `IEQ` or `IEQ` -> `POI`.

The compiled PORTA binaries are accessed through [PORTA_jll.jl](https://github.com/JuliaBinaryWrappers/PORTA_jll.jl)

!!! note "File IO and Temp Files"
    The PORTA binaries write/read data to/from file. This software functions by
    writing PORTA input to a temp file, running the binary, and then reading the
    output from a file created by the PORTA binary.

    By default, all intermediate files are written to a `porta_tmp/` directory. At
    the end of computation, data is passed back to the julia process and `porta_tmp/`
    is deleted. This functionality is intended to prevent the local filesystem
    from becoming polluted with temp files.

    Please note that in the case of failure `porta_tmp/` may not get deleted.
"""
module PORTA

# Module we are wrapping
using PORTA_jll

using Suppressor

export POI, IEQ # types
export traf     # xporta methods

# including local files
include("./types.jl")
include("./filesystem.jl") # utilities for create and removing directories
include("./file_io.jl")    # read/write functionality
include("./xporta.jl")     # wrapper for the xporta binaries.

end # module

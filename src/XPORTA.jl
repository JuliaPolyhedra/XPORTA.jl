"""
The main module of XPORTA.jl provides an interface to the
[PORTA](http://porta.zib.de/) software. Exported types and methods use
historical names from the PORTA software.

# Exports

- [`POI`](@ref) - *Type*, The vertex representation of a polyhedra.
- [`IEQ`](@ref) - *Type*, The intersecting halfspace representation of a polyhedra.
- [`traf`](@ref) - *Method*, Converts a `POI` -> `IEQ` or `IEQ` -> `POI`.

The compiled PORTA binaries are accessed through [PORTA_jll.jl](https://github.com/JuliaBinaryWrappers/PORTA_jll.jl)

!!! note "File IO and Temp Files"
    The PORTA binaries use files to read and write data. XPORTA.jl
    writes the input to a temp file, runs the PORTA binary, and reads the
    output from a file created by PORTA.

    By default, all intermediate files are written to a `porta_tmp/` directory. At
    the end of computation, data is returned to the user and `porta_tmp/`
    is deleted. This functionality is intended to prevent the local filesystem
    from becoming polluted with temp files.

    Please note that in the case of failure `porta_tmp/` may not get deleted.
"""
module XPORTA

# Module we are wrapping
using PORTA_jll

using Suppressor

export POI, IEQ # types
export traf     # xporta methods

# including local files
include("./types.jl")
include("./filesystem.jl") # utilities for create and removing directories
include("./file_io.jl")    # read/write functionality
include("./xporta_subroutines.jl")  # wrapper for the xporta binaries.

end # module

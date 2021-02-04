"""
The main module of XPORTA.jl provides an interface to the
[PORTA](http://porta.zib.de/) software. Exported types and methods use
historical names from the PORTA software.

# Exports

*Types*
- [`POI`](@ref) - The vertex representation of a polyhedra.
- [`IEQ`](@ref) - The intersecting halfspace representation of a polyhedra.

*Methods*
- [`traf`](@ref) - Converts a `POI` -> `IEQ` or `IEQ` -> `POI`.
- [`dim`](@ref) - Given a `POI` computes the dimension and constraining equalities of the `POI` convex hull.
- [`fmel`](@ref) - Projects the linear system of `IEQ` onto a subspace using fourier-motzkin elimination.
- [`vint`](@ref) - Enumerates the integral points which satisfy the linear system specified by an `IEQ`.
- [`portsort`](@ref) - Sorts the elements of `POI` and `IEQ` structs.
- [`posie`](@ref) - Enumerates the points and rays of a `POI` which satisfy the linear system of an `IEQ`.
- [`fctp`](@ref) - Determines if inequalities are tight or violated by elements of a `POI`.

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

import Polyhedra

export POI, IEQ # types
export traf, portsort, dim, fmel # xporta methods
export fctp, posie, vint         # valid methods

# including local files
include("./types.jl")
include("./filesystem.jl") # utilities for create and removing directories
include("./file_io.jl")    # read/write functionality
include("./xporta_subroutines.jl") # wrapper for the xporta binaries.
include("./valid_subroutines.jl") # wrapper for the valid binaries
include("./polyhedron.jl")

end # module

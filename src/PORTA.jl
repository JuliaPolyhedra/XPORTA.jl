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

export POI, IEQ # types
export traf     # xporta methods

# including local files
include("./types.jl")
include("./filesystem.jl") # utilities for create and removing directories
include("./file_io.jl")    # read/write functionality
include("./xporta.jl")     # wrapper for the xporta binaries.

end # module

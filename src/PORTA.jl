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
    cleanup_porta_tmp( dir :: String )

Recursively removes `/porta_tmp` from directory `dir`.
"""
function cleanup_porta_tmp(dir::String)
    # path = string(working_directory, "/porta_tmp")
    path = string(dir*"porta_tmp")
    rm(path, force=true, recursive=true)
end


traf(x) = x + 1

end # module

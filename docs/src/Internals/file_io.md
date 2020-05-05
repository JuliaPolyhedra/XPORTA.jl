```@meta
CurrentModule = PORTA
```
# File IO

Files are used to pass data to and from the PORTA binaries. The vertex
representation is written to files with the `.poi` extension while the
halfspace representation is written to files with the `.ieq` extension

For more details regarding the `.poi` and `.ieq` file formats, please refer to the
PORTA [General File Format](https://github.com/bdoolittle/julia-porta/blob/master/README.md#general-file-format) docs.

## Reading & Writing PORTA Files

```@docs
read_poi
read_ieq
write_poi
write_ieq
```

## Temp Files (Default Usage)

By default, PORTA.jl will create the `porta_tmp/` directory to which it will write
all PORTA related files. At the end of computation, `porta_tmp/` and all of its
contents are deleted.

This functionality can be overridden by passing `cleanup = false` to the appropriate
methods, *e.g.* [`traf`](@ref).  

```@docs
make_porta_tmp
rm_porta_tmp
```

# PORTA.jl

*A julia wrapper for the PORTA polyhedral analysis software.*

!!! note "Alpha Version"
    This software is a minimal viable product. Breaking changes to its
    public and internal API will likely occur in future commits.  

## Why Use PORTA.jl?

**Reproducibility:**
* Users run the same binaries.

**Ease-of-Use:**
* No compilation of source code.
* No required knowledge of the PORTA software.
* No need to read/write files required by PORTA.

## PORTA

"*A collection of [C] routines for analyzing polytopes and polyhedra.*" -([http://porta.zib.de](http://porta.zib.de/))

[PORTA](http://porta.zib.de/) (POlyhedron Representation Transformation Algorithm) is a rational polyhedra solver.
Polyhedra are described with the vertex representation or halfspace representation.
For an introduction to PORTA and polyhedral theory please review [these slides.](http://co-at-work.zib.de/berlin2009/downloads/2009-09-22/2009-09-22-0900-CR-AW-Introduction-Porta-Polymake.pdf)

**License:** GNU Public License (GPL).

## PORTA -> PORTA.jl

The julia ecosystem provides a convenient set of tools for cross-compiling C libraries.
The process followed by `PORTA.jl` is outlined below:

1. The PORTA source code was updated to support cross-compilation and published in the [julia-porta](https://github.com/bdoolittle/julia-porta) repository.
2. The [BinaryBuilder.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl) script was used to generate and test the cross-compilation build scripts for PORTA.
3. The build script is then published to the [github.com/JuliaPackaging/Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil/tree/master/P/PORTA) repository.
4. When merged with the master branch of Yggdrasil, the [`PORTA_jll.jl`](https://github.com/JuliaBinaryWrappers/PORTA_jll.jl) module is automatically published to [JuliaBinaryWrappers](https://github.com/JuliaBinaryWrappers/) github repo.
5. `PORTA_jll` wraps the compiled PORTA binaries for all platforms enabling the PORTA binaries to easily be called with julia without users having to download or compile the source code.
6. `PORTA.jl` creates a documented and easy-to-use interface for `PORTA_jll`.

### PORTA History

The official PORTA software was originally released in 1997 and the original source
code can be found at [http://porta.zib.de](http://porta.zib.de). The original
source code is not officially maintained. As compilers and computer architectures
continue to develop, the PORTA software has become less compatible with modern environments.

In April 2014, github user [denisrosset](https://github.com/denisrosset) uploaded the PORTA source code to [github.com/denisrosset/porta](https://github.com/denisrosset/porta).
Minimal changes were made to the source code fixing compilation errors on Mac OSX.

In April 2020, github user [bdoolittle](https://github.com/bdoolittle/) forked denisrosset's PORTA repository
creating the repository [github.com/bdoolittle/julia-porta](https://github.com/bdoolittle/julia-porta).
The `julia-porta` repository houses the PORTA source code exposed through julia.
In this repository minimal changes were made to the codebase and `Makefile` enabling
cross-compilation for supported julia platforms. Furthermore, the `julia-porta`
repository exposed the official PORTA documentation in the `README` making the
documentation easily accessible. Throughout this project, references to the PORTA
documentation will point to the `julia-porta` repository, but let it be noted that
the documentation found there is taken from the documentation found throughout
the PORTA source code.

As of May 2020, there are a number of open forks of denisrosset's PORTA repository.
These forks represent a new interest of an old software. Given that there exists
a current base of PORTA users, it is likely that a community of PORTA users will
take over the task of maintaining the PORTA source code.


## Project Philosophy

##

```@index
```

```@autodocs
Modules = [PORTA]
```

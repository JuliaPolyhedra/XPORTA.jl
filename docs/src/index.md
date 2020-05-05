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

1. The PORTA source and Makefile were updated to support cross-compilation and published to the [julia-porta](https://github.com/bdoolittle/julia-porta) repository.
2. The [BinaryBuilder.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl) script was used to generate and test the cross-compilation build scripts for PORTA.
3. The build script is then published to the [github.com/JuliaPackaging/Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil/tree/master/P/PORTA) repository.
4. When merged with the master branch of Yggdrasil, the [`PORTA_jll.jl`](https://github.com/JuliaBinaryWrappers/PORTA_jll.jl) module is automatically published to [JuliaBinaryWrappers](https://github.com/JuliaBinaryWrappers/) github repo.
5. `PORTA_jll` wraps the compiled PORTA binaries for all platforms enabling the PORTA binaries to easily be called with julia without users having to download or compile the source code.
6. `PORTA.jl` creates a documented and easy-to-use interface for `PORTA_jll`.

#### PORTA History

The official PORTA software was released in 1997 and the original source
code can be found at [http://porta.zib.de](http://porta.zib.de). The original
source code is not officially maintained. As compilers and computer architectures
continue to develop, the PORTA software has become less compatible with modern environments.

In April 2014, github user [denisrosset](https://github.com/denisrosset) uploaded the PORTA source code to [github.com/denisrosset/porta](https://github.com/denisrosset/porta).
Minimal changes were made to the source code fixing compilation errors on Mac OSX.

As of May 2020, there are a number of open forks of denisrosset's PORTA repository.
The [julia-porta](https://github.com/bdoolittle/julia-porta) repo on which this project is based is one such case.
These forks represent a new interest of an old software. Given that there exists
a current base of PORTA users, it is likely that a community of PORTA users will
take over the task of maintaining the PORTA source code.


## Philosophy

`PORTA.jl` aims to satisfy user needs over complete implementation of PORTA methods.
Please reach out <where to reach out> if there is functionality you would like implemented.


```@index
```

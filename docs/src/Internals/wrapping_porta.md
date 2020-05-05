# Wrapping PORTA

## PORTA -> PORTA.jl

The julia ecosystem provides a convenient set of tools for cross-compiling C libraries.
The process followed by `PORTA.jl` is outlined below:

1. The PORTA source code is forked from the [github.com/denisrosset/porta](https://github.com/denisrosset/porta) repository to [github.com/bdoolittle/julia-porta](https://github.com/bdoolittle/julia-porta). Forking the source enables:
    * Weblinks to be made directly from these docs to the [PORTA documentation](https://github.com/bdoolittle/julia-porta/blob/master/README.md#porta-documentation).
    * Updates to be made to the GNU Makefile enabling cross-platform compilation.
    * Compilation errors to be fixed.


2. The [BinaryBuilder.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl) script is used to generate and test the cross-compilation [build script](https://github.com/JuliaPackaging/Yggdrasil/tree/master/P/PORTA) for PORTA.
    * The build script runs against a specific commit to the julia-porta repo ensuring that all users run the same PORTA binaries.
    * The [`PORTA_jll.jl`](https://github.com/JuliaBinaryWrappers/PORTA_jll.jl) module is auto-generated and published to the [JuliaBinaryWrappers](https://github.com/JuliaBinaryWrappers/) github repo.


3. `PORTA_jll.jl` wraps the compiled PORTA binaries and executes the correct binary for the environment in which julia is running.
    * Binaries are easily called through julia without requiring users to download or compile the source code.
    * `PORTA_jll.jl` is not a complete wrapper because it lacks, testing, documentation and requires users to handle PORTA specific file IO tasks.


4. The `PORTA.jl` package is an easy-to-use interface for `PORTA_jll`.
    * The package handles cumbersome read/write tasks.
    * The package is well tested and documented.


## PORTA History

The official PORTA software was released in 1997 and the source
code can be found at [http://porta.zib.de](http://porta.zib.de). The source code
is not actively maintained and as a result, PORTA has become incompatible with some
computing environments.

In April 2014, github user [denisrosset](https://github.com/denisrosset) uploaded
the PORTA source code to [github.com/denisrosset/porta](https://github.com/denisrosset/porta).
Minimal changes were made to the source code fixing compilation errors on Mac OSX.

As of May 2020, there are a number of open forks of denisrosset's PORTA repository.
The [julia-porta](https://github.com/bdoolittle/julia-porta) repo is one such case.
These forks represent a new interest of an old software. Given a current base of
PORTA users, it is possible that the community will absorb the task of maintaining
the PORTA source code.

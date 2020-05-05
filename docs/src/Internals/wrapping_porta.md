# Wrapping PORTA

## PORTA History

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


## PORTA -> PORTA.jl

The julia ecosystem provides a convenient set of tools for cross-compiling C libraries.
The process followed by `PORTA.jl` is outlined below:

1. The PORTA source and Makefile were updated to support cross-compilation and published to the [julia-porta](https://github.com/bdoolittle/julia-porta) repository.
2. The [BinaryBuilder.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl) script was used to generate and test the cross-compilation build scripts for PORTA.
3. The build script is then published to the [github.com/JuliaPackaging/Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil/tree/master/P/PORTA) repository.
4. When merged with the master branch of Yggdrasil, the [`PORTA_jll.jl`](https://github.com/JuliaBinaryWrappers/PORTA_jll.jl) module is automatically published to [JuliaBinaryWrappers](https://github.com/JuliaBinaryWrappers/) github repo.
5. `PORTA_jll` wraps the compiled PORTA binaries for all platforms enabling the PORTA binaries to easily be called with julia without users having to download or compile the source code.
6. `PORTA.jl` creates a documented and easy-to-use interface for `PORTA_jll`.

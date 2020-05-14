# Development Guide

#### Some notes on development:
* Features will be added on a needs basis.
* Code should be tested, documented, and organized.
* Naming schemes should follow the precedent of the PORTA software.

## Contributing

Please reach out to brian.d.doolittle@gmail.com if you are interested in making
a contribution to PORTA.jl.

## Testing

All commits should be tested. Tests may be run from the command line,

```
$ julia test/runtests.jl
```

or via `Pkg` (within the julia REPL),

```
julia> ]test PORTA
```  

Note: the `]` character invokes `Pkg` REPL `(@v#.#) pkg>`.

#### Test Types

* Unit Tests `test/unit/` - verify the behavior and logic of julia methods.
* Integration Tests `test/integration` - verify file IO and binary execution.
* Regression Tests `test/regression/` - verify the correctness of end-to-end functionality.

## Docs

All features should be documented. Documentation is created using the
[Documenter.jl](https://juliadocs.github.io/Documenter.jl/stable/) framework.

To build docs locally, run

```
$ julia docs/make.jl
```

To locally host the docs website, navigate to `/docs/build` and run

```
$ python3 -m http.server --bind localhost
```

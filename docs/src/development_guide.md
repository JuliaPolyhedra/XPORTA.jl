# Development Guide

## Philosophy

It doesn't matter if software is "complete" as that is ill defined. It matters
that software works and is high-quality throughout. Development on this project
focuses on small high-quality features.

Some notes on development:
* Additional features will be added on a needs basis.
* Quality code should be tested, documented, and organized.
* Naming schemes introduced in the PORTA software should be re-used in PORTA.jl.

## Contributing

Please reach out if you are interested in making a contribution to PORTA.jl. Contributions
should be fully tested and documented.

## Testing

Every method written should be tested. To run all tests from the command line call,

```
$ julia test/runtests.jl
```

or to run all tests via package (within the julia REPL)

```
julia> ]test PORTA
```  

Note the `]` character invokes Pkg REPL `(@v#.#) pkg>`.

#### Unit Tests: `test/unit/`
Unit tests verify the behavior and logic of julia methods.

#### Integration Tests: `test/integration`
Integration tests verify file IO and binary behavior.

#### Regression Tests: `test/regression/`
Regression tests verify the correctness of end-to-end functionality.

## Docs

Documentation is created using the [Documenter.jl](https://juliadocs.github.io/Documenter.jl/stable/) framework.
All written code should be documented.

To build the docs locally run:

```
$ julia docs/make.jl
```

The docs website can be locally hosted from the build directory with the command:

```
$ python3 -m http.server --bind localhost
```

Note that the command must be run from the `docs/build` directory.

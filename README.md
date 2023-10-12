# XPORTA.jl (ALPHA)

*A julia wrapper for the [PORTA](http://porta.zib.de/) polyhedral analysis software.*

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaPolyhedra.github.io/XPORTA.jl/dev)[![Test Status](https://github.com/JuliaPolyhedra/XPORTA.jl/actions/workflows/run_tests.yml/badge.svg)](https://github.com/JuliaPolyhedra/XPORTA.jl/actions/workflows/run_tests.yml)

XPORTA provides two features:

 - a thin wrapper around the complete PORTA API
 - an interface to [Polyhedra](https://github.com/JuliaPolyhedra/Polyhedra.jl)

## Documentation

* XPORTA.jl documentation: [JuliaPolyhedra.github.io/XPORTA.jl/dev/](https://JuliaPolyhedra.github.io/XPORTA.jl/dev/)
* Julia distribution of PORTA: [github.com/bdoolittle/julia-porta](https://github.com/bdoolittle/julia-porta)
* Legacy PORTA software: [http://porta.zib.de](http://porta.zib.de/)

## Licensing

PORTA and XPORTA.jl are licensed under the GNU General Public License (GPL) v2.0.

## Use with Polyhedra

To use XPORTA with Polyhedra, use `XPORTA.Library`:

```julia
using Polyhedra, XPORTA
h = hrep(...)
p = polyhedron(h, XPORTA.Library())
```

## Acknowledgments

Development of XPORTA.jl was made possible by the advisory of Dr. Eric Chitambar
and general support from the Physics Department at the University of Illinois
Urbana-Champaign. Funding was provided by NSF Award 1914440.

## Citing

See `PORTA_CITATION.bib` for the relevant references.

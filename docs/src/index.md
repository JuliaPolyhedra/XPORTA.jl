# PORTA.jl

*A julia wrapper for the PORTA polyhedral analysis software.*

!!! note "Alpha Version"
    PORTA.jl is a minimal viable product. Breaking changes may occur in future commits.

## PORTA.jl Features
* Read/Write utilities for PORTA files.
* File IO handler for PORTA routines.

## Why Use PORTA.jl?

#### Ease-of-Use
* No compilation of source code.
* No required knowledge of the PORTA software.
* No need to read/write files required by PORTA.

#### Reproducibility
* Users all run the same PORTA binaries.

## PORTA Software

*"A collection of [C] routines for analyzing polytopes and polyhedra."* -([http://porta.zib.de](http://porta.zib.de/))

[PORTA](http://porta.zib.de/) (POlyhedron Representation Transformation Algorithm) is a rational polyhedral solver.
Polyhedra are described either by the vertex representation or by the halfspace representation.
For an introduction to PORTA and polyhedral theory please review [these slides.](http://co-at-work.zib.de/berlin2009/downloads/2009-09-22/2009-09-22-0900-CR-AW-Introduction-Porta-Polymake.pdf)


## Licensing

PORTA and PORTA.jl are licensed under the GNU General Public License (GPL) v2.0.

## Acknowledgments

Development of Porta.jl was made possible by the advisory
of Dr. Eric Chitambar and general support from the Physics Department at the
University of Illinois Urbana-Champaign. Funding was provided by NSF Award 1914440.

## Citing

See `PORTA_CITATION.bib` for the relevant references.

## Contents

```@contents
Pages = ["user_guide.md", "exports.md", "Internals/wrapping_porta.md", "Internals/file_io.md", "Internals/binaries.md", "development_guide.md"]
Depth = 1
```

## Index

#### Exports
```@index
Pages = ["exports.md"]
```

#### File IO
```@index
Pages = ["Internals/file_io.md"]
```
#### Binary Calls
```@index
Pages = ["Internals/binaries.md"]
```

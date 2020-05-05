# PORTA.jl

*A julia wrapper for the PORTA polyhedral analysis software.*

!!! note "Alpha Version"
    This software is a minimal viable product. Breaking changes to its
    public and internal API will likely occur in future commits.  

## Why Use PORTA.jl?

**Reproducibility:**
* Users all run the same PORTA binaries.

**Ease-of-Use:**
* No compilation of source code.
* No required knowledge of the PORTA software.
* No need to read/write files required by PORTA.

## PORTA Overview

*"A collection of [C] routines for analyzing polytopes and polyhedra."* -([http://porta.zib.de](http://porta.zib.de/))

[PORTA](http://porta.zib.de/) (POlyhedron Representation Transformation Algorithm) is a rational polyhedra solver.
Polyhedra are described either by the vertex representation or by the halfspace representation.
For an introduction to PORTA and polyhedral theory please review [these slides.](http://co-at-work.zib.de/berlin2009/downloads/2009-09-22/2009-09-22-0900-CR-AW-Introduction-Porta-Polymake.pdf)

**License:** GNU Public License (GPL).

## Contents

```@contents
Pages = ["user_guide.md", "Internals/wrapping_porta.md", "Internals/file_io.md", "Internals/binaries.md", "development_guide.md"]
Depth = 1
```

## Index

```@index
```

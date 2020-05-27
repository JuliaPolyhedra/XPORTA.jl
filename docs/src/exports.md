```@meta
CurrentModule = XPORTA
```
# Exports

```@docs
XPORTA
```

## Types

```@docs
PortaMatrix
POI
IEQ
```

## Methods

!!! note "Temp Files"
    By default, files created by the PORTA binaries are deleted. When performing
    longer computations with PORTA, it may be desirable to keep intermediate files.
    The argument, `cleanup = false`, causes XPORTA.jl methods to write files to
    the directory specified by the `dir` argument.

```@docs
traf
portsort
posie
fctp
vint
```

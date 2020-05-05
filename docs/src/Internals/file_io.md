```@meta
CurrentModule = PORTA
```
# File IO

Files are used to pass data to and from the PORTA binaries. Data using the vertex
representation is written to files with the `.poi` extension while data using the
halfspace representation is written to files with the `.ieq` extension.

## Reading & Writing PORTA Files

```@docs
read_poi
read_ieq
write_poi
write_ieq
```

## Temp Files (Default Usage)

```@docs
make_porta_tmp
rm_porta_tmp
```

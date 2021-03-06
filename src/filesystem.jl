"""
    make_porta_tmp( dir::String = "./") :: String

Creates the `porta_tmp/` directory in directory `dir` and returns the `porta_tmp` path.
"""
function make_porta_tmp(dir::String="./") :: String
    sep = occursin(r"/$", dir) ? "" : "/"
    mkpath(dir * sep * "porta_tmp")
end

"""
    rm_porta_tmp( dir::String = "./")

Recursively removes `porta_tmp/` from directory `dir`.

!!! warning
    This method uses `rm("<dir/>porta_tmp/", force=true, recursive=true)`. Make
    sure not to delete important data.
"""
function rm_porta_tmp(dir::String="./")
    rm(dir*"porta_tmp/", force=true, recursive=true)
end

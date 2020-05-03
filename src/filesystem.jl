"""
    make_tmp_dir( dir::String = "./", tmp_dir::String = "porta_tmp") :: String

Creates the `tmp_dir` directory within `dir` and return the `tmp_dir` path. By
default, the created directory is `./porta_tmp`.
"""
function make_tmp_dir(;dir::String="./", tmp_dir::String="porta_tmp") :: String
    mkpath(dir*tmp_dir)
end

"""
    cleanup_porta_tmp( dir::String = "./")

Recursively removes `porta_tmp/` from directory `dir`.

!!! warning
    This method uses `rm("<dir/>porta_tmp/", force=true, recursive=true)`. Make
    sure not to delete important data.
"""
function cleanup_porta_tmp(;dir::String="./")
    rm(dir*"porta_tmp/", force=true, recursive=true)
end

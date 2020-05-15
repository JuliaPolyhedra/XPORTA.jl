using Documenter, PORTA

makedocs(;
    modules=[PORTA],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "User Guide" => "user_guide.md",
        "Exports" => "exports.md",
        "Internals" => [
            "Wrapping PORTA" => "Internals/wrapping_porta.md",
            "File IO" => "Internals/file_io.md",
            "Binaries" => "Internals/binaries.md",
        ],
        "Development Guide" => "development_guide.md"
    ],
    repo="https://github.com/JuliaPolyhedra/PORTA.jl/blob/{commit}{path}#L{line}",
    sitename="PORTA.jl",
    authors="Brian Doolittle",
)

deploydocs(;
    repo="github.com/JuliaPolyhedra/PORTA.jl.git",
)

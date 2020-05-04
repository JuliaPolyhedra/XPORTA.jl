using Documenter, PORTA

makedocs(;
    modules=[PORTA],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "User Guide" => "user_guide.md",
        "Internals" => [
            "File IO" => "Internals/file_io.md",
            "Xporta" => "Internals/xporta.md",
        ],
        "Development Guide" => "development_guide.md"
    ],
    repo="https://github.com/bdoolittle/PORTA.jl/blob/{commit}{path}#L{line}",
    sitename="PORTA.jl",
    authors="Brian Doolittle",
    # assets=String[],
)

deploydocs(;
    repo="github.com/bdoolittle/PORTA.jl.git",
    # push_preview=true,
)

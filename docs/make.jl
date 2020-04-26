using Documenter, PORTA

makedocs(;
    modules=[PORTA],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/bdoolittle/PORTA.jl/blob/{commit}{path}#L{line}",
    sitename="PORTA.jl",
    authors="Brian Doolittle",
    # assets=String[],
)

deploydocs(;
    repo="github.com/bdoolittle/PORTA.jl.git",
    push_preview=true,
    devbranch = "master",
    devurl = "dev",
    versions = ["stable" => "v^", "v#.#", devurl => devurl],
)

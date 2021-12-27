if VERSION < v"1.8.0-DEV.410"
    using Base: @_inline_meta
else
    const var"@_inline_meta" = Base.var"@inline"
end

function define_docstrings()
    docstrings = [:Historic => joinpath(dirname(@__DIR__), "README.md")]
    docsdir = joinpath(@__DIR__, "docs")
    for filename in readdir(docsdir)
        stem, ext = splitext(filename)
        ext == ".md" || continue
        name = Symbol(stem)
        name in names(Historic, all = true) || continue
        push!(docstrings, name => joinpath(docsdir, filename))
    end
    for (name, path) in docstrings
        include_dependency(path)
        doc = read(path, String)
        doc = replace(doc, r"^```julia"m => "```jldoctest $name")
        doc = replace(doc, "<kbd>TAB</kbd>" => "_TAB_")
        @eval Historic $Base.@doc $doc $name
    end
end

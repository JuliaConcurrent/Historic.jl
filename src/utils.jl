if VERSION < v"1.8.0-DEV.410"
    using Base: @_inline_meta
else
    const var"@_inline_meta" = Base.var"@inline"
end

function contextualized_buffer(io::IO)
    buffer = IOBuffer()
    ctx = IOContext(buffer, io)
    ctx = IOContext(ctx, :displaysize => displaysize(io))
    return (ctx, buffer)
end

function printing(f, io::IO)
    (ctx, buffer) = contextualized_buffer(io)
    y = f(ctx)
    seekstart(buffer)
    write(io, take!(buffer))
    return y
end

function printing_in_oneline(f, io::IO)
    (ctx, buffer) = contextualized_buffer(io)
    width = displaysize(io)[2] - 3
    last_valid = Ref(position(buffer))
    is_truncated = Ref(false)
    function should_stop()
        local p = position(buffer)
        if p >= width
            is_truncated[] = true
            return true
        else
            last_valid[] = p
            return false
        end
    end
    y = f(ctx, should_stop)

    if is_truncated[]
        truncate(buffer, last_valid[])
        printstyled(ctx, "..."; color = :light_black)
    end
    println(ctx)

    seekstart(buffer)
    write(io, take!(buffer))
    return y
end
# TODO: accurate width with colors and unicodes (instead of `position`)?

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

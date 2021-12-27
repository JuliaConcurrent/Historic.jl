function mapcolumns(f, cols)
    columnnames = Symbol[]
    columndict = Dict{Symbol,Vector}()
    nums = Int[]
    for (k, v) in pairs(cols)
        v = f(v)
        if v !== nothing
            columndict[k] = v
            push!(columnnames, k)
            push!(nums, length(v))
        end
    end
    isempty(columnnames) && return NamedTuple()
    @assert all(==(nums[1]), nums)
    return (; (k => columndict[k] for k in columnnames)...)
end

function ishomogenous(xs)
    y = iterate(xs)
    y === nothing && return true
    x1, s = y
    while true
        y = iterate(xs, s)
        y === nothing && return true
        x, s = y
        isequal(x, x1) || return false
    end
end

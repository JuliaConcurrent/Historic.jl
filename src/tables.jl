function Historic.events(recordmodule::Module)
    # TODO: recursively discover recorder modules
    records = recordmodule.get_records()::EventRecord
    table = append_events!(empty_eventtable(), records)
    Threads.nthreads() == 1 && return table
    return sort_eventtable(table)
end

function Historic.events()
    table = empty_eventtable()
    for recordmodule in RECORDERS
        records = recordmodule.get_records()::EventRecord
        append_events!(table, records)
    end
    return sort_eventtable(table)
end

function empty_eventtable()
    return (
        name = Symbol[],
        data = NamedTuple[],
        location = UUID[],
        __source__ = Union{LineNumberNode,Nothing}[],
        __module__ = Union{Module,Nothing}[],
        time_ns = TimeNS[],
        threadid = Int[],
    )
end

function append_events!(table, records)
    for (threadid, shard) in pairs(records.shards)
        a = length(table.name)
        append_sharded_events!(table, shard)

        b = length(table.name)
        resize!(table.threadid, b)
        fill!(view(table.threadid, a+1:b), threadid)
    end
    return table
end

function append_sharded_events!(table, shard)
    for blk in blocks(shard)
        for i in eachindex(blk)
            event = @inbounds blk[i]
            ntuple(Val(nfields(event))) do j
                @_inline_meta
                push!(getfield(table, j), getfield(event, j))
                nothing
            end
        end
    end
end

function sort_eventtable(table)
    # TODO: since each shard is sorted, it'd be much more efficient to use "mergesorted!"
    idx = sortperm(table.time_ns)
    cols = ntuple(Val(nfields(table))) do j
        @_inline_meta
        (; fieldname(typeof(table), j) => getfield(table, j)[idx])
    end
    return foldl(merge, cols)
end

Historic.flattable(recordmodule::Module) = Historic.flattable(Historic.events(recordmodule))
Historic.flattable() = Historic.flattable(Historic.events())

function Historic.flattable(eventtable::NamedTuple)
    table = merge(_flattable(eventtable.data), eventtable)
    ks = filter(!=(:data), keys(table))
    return NamedTuple{(ks...,)}(table)
end

function _flattable(rows)
    columnnames = Symbol[]
    columndict = Dict{Symbol,Vector}()
    nrows = 0
    for nt in rows
        for (k, v) in pairs(nt)
            c = get(columndict, k, nothing)
            if c === nothing
                if nrows > 0
                    c = Vector{Union{Missing,typeof(v)}}(undef, nrows + 1)
                    fill!(c, missing)
                    c[end] = v
                else
                    c = [v]
                end
                columndict[k] = c
                push!(columnnames, k)
            else
                T = promote_type(typeof(v), eltype(c))
                n = length(c)
                if nrows > n
                    T = Union{T,Missing}
                end
                if !(T <: eltype(c))
                    columndict[k] = c = collect(T, c)
                end
                resize!(c, nrows + 1)
                if nrows > n
                    fill!(view(c, n+1:nrows), missing)
                end
                c[end] = v
            end
        end
        nrows += 1
    end
    for (k, v) in pairs(columndict)
        columndict[k] = grow_with_missing!(v, nrows)
    end
    return (; (k => columndict[k] for k in columnnames)...)
end

function grow_with_missing!(v::AbstractVector, n)
    @assert firstindex(v) == 1
    T = Union{Missing,eltype(v)}
    m = length(v)
    m == n && return v
    @assert m < n
    if !(T <: eltype(v))
        v = collect(T, v)
    end
    resize!(v, n)
    fill!(view(v, m+1:n), missing)
    return v
end

HistoricAnalysis.unstack_tasks(; options...) =
    HistoricAnalysis.unstack_tasks(Historic.events(); options...)

HistoricAnalysis.unstack_tasks(recordmodule::Module; options...) =
    HistoricAnalysis.unstack_tasks(Historic.events(recordmodule); options...)

function HistoricAnalysis.unstack_tasks(table; options...)
    table = HistoricAnalysis.simplified(table; options...)
    long = DataFrame(table)
    long[!, :taskname], mapping = tasknames(long.taskid)
    wide = unstack(long, :taskname, :name)

    left = ["task$n" for n in 1:length(mapping)]
    right = ["taskid"]
    cols = union(left, setdiff!(names(wide), intersect(right, names(wide))))
    append!(cols, right)
    return select!(wide, cols)
end

function tasknames(taskids)
    mapping = Dict{eltype(taskids),String}()
    ntasks = Ref(0)
    ys = if Missing <: eltype(taskids)
        Union{String,Missing}[]
    else
        String[]
    end
    for id in taskids
        if id === missing
            push!(ys, missing)
            continue
        end
        y = get!(mapping, id) do
            n = ntasks[] += 1
            "task$n"
        end
        push!(ys, y)
    end
    @assert length(taskids) == length(ys)
    return ys, mapping
end

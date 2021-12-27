HistoricAnalysis.simplified(; options...) =
    HistoricAnalysis.simplified(Historic.events(); options...)

HistoricAnalysis.simplified(recordmodule::Module; options...) =
    HistoricAnalysis.simplified(Historic.events(recordmodule); options...)

function HistoricAnalysis.simplified(table; prune::Bool = true)
    if :data in Tables.columnnames(table)
        if table isa NamedTuple
            table = Historic.flattable(table)
        else
            table = Historic.flattable(Tables.columntable(table))
        end
    end
    if prune
        table = mapcolumns(table) do c
            if ishomogenous(skipmissing(c))
                return nothing
            else
                return c
            end
        end
    end
    return table
end

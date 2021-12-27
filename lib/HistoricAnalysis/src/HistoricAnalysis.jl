baremodule HistoricAnalysis

function simplified end
function unstack_tasks end

module Internal

using DataFrames
using Tables

import Historic
using Historic.Internal: EventRecord

using ..HistoricAnalysis: HistoricAnalysis

include("utils.jl")
include("simplified.jl")
include("unstack_tasks.jl")

end  # module Internal

end  # baremodule HistoricAnalysis

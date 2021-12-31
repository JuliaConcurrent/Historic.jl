baremodule Historic

macro define end
# macro define_static end

function clear end
function events end
function flattable end
function recorders end

# Tools
function taskprefix end
function taskdata end
function taskid end
function objid end
function uniqueid end

const defaultprefix = taskprefix
const defaultdata = taskdata

module Internal

import ..Historic: @define
using ..Historic: Historic

using Base.Meta: isexpr
using Logging: Logging, AbstractLogger, current_logger, handle_message
using UUIDs: UUID, uuid4

include("BlockLinkedLists.jl")
using .BlockLinkedLists: BlockLinkedList, blocks

include("utils.jl")
include("define.jl")
include("recording.jl")
include("logging.jl")
include("defaultlogger.jl")
include("id.jl")
include("tools.jl")
# include("blockinglogger.jl")
include("accessors.jl")
include("tables.jl")

function __init__()
    init_unique_id()
end

end  # module Internal

@define Scratch
using .Scratch: @record

Internal.define_docstrings()

end  # baremodule Historic

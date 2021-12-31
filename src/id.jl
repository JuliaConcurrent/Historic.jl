abstract type AbstractID end
Base.UInt(id::AbstractID) = id.value
idstr(id::AbstractID) = string(UInt(id); base = 16, pad = Sys.WORD_SIZE >> 2)
idprefix(::AbstractID) = ""

Base.print(io::IO, id::AbstractID) = print(io, idprefix(id), idstr(id))

function Base.show(io::IO, id::AbstractID)
    if get(io, :typeinfo, Any) <: Union{typeof(id),Missing,Nothing}
        show(io, UInt(id))
    else
        invoke(show, Tuple{IO,Any}, io, id)
    end
end

struct TaskID <: AbstractID
    value::UInt
end

TaskID(task::Task) = TaskID(UInt(pointer_from_objref(task)))
idprefix(::TaskID) = "task:"

struct ObjectID <: AbstractID
    value::UInt

    function ObjectID(x)
        if ismutable(x)
            new(UInt(pointer_from_objref(x)))
        else
            new(objectid(x))
        end
    end
end

Historic.taskid(task::Task = current_task()) = TaskID(task)
Historic.objid(x) = ObjectID(x)

const LAST_UNIQUE_ID = UInt64[]
unique_id_index(tid = Threads.threadid()) = tid * 8

function init_unique_id()
    resize!(LAST_UNIQUE_ID, Threads.nthreads() * 8)
    fill!(LAST_UNIQUE_ID, 0)
    for tid in 1:Threads.nthreads()
        LAST_UNIQUE_ID[unique_id_index(tid)] = tid
    end
end

Historic.uniqueid() = LAST_UNIQUE_ID[unique_id_index()] += Threads.nthreads()

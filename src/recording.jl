const TimeNS = typeof(time_ns())

struct Event
    name::Symbol
    data::NamedTuple
    location::UUID
    __source__::Union{LineNumberNode,Nothing}
    __module__::Union{Module,Nothing}
    time_ns::TimeNS
end

const EVENT_BLOCKSIZE = Ref(1024)

thread_local_event_records() = BlockLinkedList(Vector{Event}, EVENT_BLOCKSIZE[])

# TODO: thread safety
struct EventRecord
    shards::Vector{typeof(thread_local_event_records())}
end

create_records() = init_records!(EventRecord(Union{}[]))

function init_records!(records::EventRecord)
    resize!(records.shards, Threads.nthreads())
    for i in eachindex(records.shards)
        records.shards[i] = thread_local_event_records()
    end
    return records
end

function record!(
    records::EventRecord,
    name::Symbol,
    data::NamedTuple;
    location::UUID = UUID(0),
    __source__::Union{LineNumberNode,Nothing} = nothing,
    __module__::Union{Module,Nothing} = nothing,
    time_ns::TimeNS = time_ns(),
    # Ignored:
    log::NamedTuple = NamedTuple(),
)
    event = Event(name, data, location, __source__, __module__, time_ns)
    push!(records.shards[Threads.threadid()], event)
    return event
end

function Base.empty!(records::EventRecord)
    foreach(empty!, records.shards)
    return records
end

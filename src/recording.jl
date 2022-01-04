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

const EventRecordShard = typeof(thread_local_event_records())

# TODO: thread safety
mutable struct EventRecord
    @atomic shards::Vector{EventRecordShard}
end

new_shards() = EventRecordShard[thread_local_event_records() for _ in 1:Threads.nthreads()]

create_records() = init_records!(EventRecord(Union{}[]))
init_records!(records::EventRecord) = empty!(records)

function Base.empty!(records::EventRecord)
    shards = new_shards()
    @atomic records.shards = shards
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
    shards = @atomic records.shards
    push!(shards[Threads.threadid()], event)
    return event
end

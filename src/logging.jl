struct CurrentLogger end
const LoggerLike = Union{CurrentLogger,AbstractLogger}

as_logger(logger::AbstractLogger) = logger
as_logger(::CurrentLogger) = current_logger()

should_log(options) = get(options, :log, NamedTuple()) !== nothing

streamtype(::AbstractLogger) = IO
may_yield(::IO) = true
may_yield(logger::AbstractLogger) = may_yield(streamtype(logger))
may_yield(::CurrentLogger) = may_yield(current_logger())
# TODO: Define a blocking `IO` wrapping `Core.print` and a logger factory using
# it.

function logrecord(
    logger::LoggerLike,
    name::Symbol,
    data::NamedTuple,
    prefix;
    location::UUID = UUID(0),
    __source__::Union{LineNumberNode,Nothing} = nothing,
    __module__::Union{Module,Nothing} = nothing,
    log::NamedTuple = NamedTuple(),
    # Ignored:
    time_ns = nothing,
)
    msg = sprint() do io
        print(io, prefix)
        if prefix isa AbstractString && !endswith(prefix, ' ')
            print(io, ' ')
        end
        print(io, name)
    end
    filepath = "???"
    line::Int = 0
    if __source__ !== nothing
        if __source__.file !== nothing
            filepath = string(__source__.file)
        end
        line = __source__.line
    end
    group = :Historic
    handle_message(
        as_logger(logger),
        Logging.Info,
        msg,
        something(__module__, Main),
        group,
        location,
        filepath,
        line;
        data...,
    )
end

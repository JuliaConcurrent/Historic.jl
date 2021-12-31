struct DefaultLogger{IO,Fallback<:AbstractLogger} <: AbstractLogger
    io::IO
    fallback::Fallback
end

DefaultLogger() = DefaultLogger(stderr, current_logger())

function kwarg_sortkey(x)
    k, v = x
    cost = if v isa Union{Number,Symbol}
        0
    elseif v isa AbstractString
        1
    elseif v isa TaskID && k === :taskid  # TODO: get rid of this heuristics?
        200
    elseif v isa AbstractID
        -1
    else
        100
    end
    return (cost, k)
end

function Logging.handle_message(
    logger::DefaultLogger,
    level::Logging.LogLevel,
    message,
    _module,
    group,
    id,
    filepath,
    line;
    exception = nothing,
    kwargs...,
)
    @nospecialize(kwargs)
    if exception !== nothing
        handle_message(
            logger.fallback,
            level,
            message,
            _module,
            group,
            id,
            filepath,
            line;
            exception,
            kwargs...,
        )
    end
    kvs = sort!(collect(Pair{Symbol,Any}, kwargs); by = kwarg_sortkey)
    printing_in_oneline(logger.io) do io, should_stop
        if level != Logging.Info
            printstyled(io, level; color = :blue)
            print(io, ": ")
        end
        print(io, message)
        should_stop() && return
        for (k, v) in kvs
            print(io, ' ', k, '=')
            print(io, v)  # dynamic dispatch
            should_stop() && return
        end
    end
end

# These are unused but just for making it a proper logger:
Logging.shouldlog(logger::DefaultLogger, level, _module, group, id) = true
Logging.min_enabled_level(::DefaultLogger) = Logging.Info

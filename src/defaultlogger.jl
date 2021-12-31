struct DefaultLogger{IO,Fallback<:AbstractLogger} <: AbstractLogger
    io::IO
    fallback::Fallback
end

DefaultLogger() = DefaultLogger(stderr, current_logger())

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
    printing_in_oneline(logger.io) do io, should_stop
        if level != Logging.Info
            printstyled(io, level; color = :blue)
            print(io, ": ")
        end
        print(io, message)
        should_stop() && return
        for (k, v) in kwargs
            print(io, ' ', k, '=')
            print(io, v)
            should_stop() && return
        end
    end
end

# These are unused but just for making it a proper logger:
Logging.shouldlog(logger::DefaultLogger, level, _module, group, id) = true
Logging.min_enabled_level(::DefaultLogger) = Logging.Info

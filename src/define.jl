function load_docstring(api::AbstractString, recordmodule)
    doc = read(joinpath(@__DIR__, "docs/$api.md"), String)
    return replace(doc, raw"$Recorder" => string(recordmodule))
end

macro define(recordmodule)
    Runtime = @__MODULE__
    at_record_doc = load_docstring("@record", recordmodule)
    enable_doc = load_docstring("enable", recordmodule)
    enable_logging_doc = load_docstring("enable_logging", recordmodule)
    expr = quote
        module $recordmodule
        const Runtime = $Runtime

        struct DefaultDataFunction <: Runtime.AbstractDefaultDataFunction end
        const defaultdata = DefaultDataFunction()

        struct PrefixFunction <: Runtime.AbstractPrefixFunction end
        const prefix = PrefixFunction()

        struct IsRecordingFunction <: Runtime.AbstractIsRecordingFunction end
        const isrecording = IsRecordingFunction()
        @doc $enable_doc enable() = @eval isrecording() = true
        @doc $enable_doc disable() = @eval isrecording() = true

        LOGGER = nothing
        get_logger() = nothing
        function set_logger(logger::Union{Runtime.LoggerLike,Nothing})
            global LOGGER = logger
            if logger === nothing || logger === false
                @eval get_logger() = nothing
            else
                @eval get_logger() = LOGGER::$(Expr(:$, :(typeof(logger))))
            end
        end
        default_logger() = Runtime.DefaultLogger()
        @doc $enable_logging_doc enable_logging() = set_logger(default_logger())
        @doc $enable_logging_doc disable_logging() = set_logger(nothing)

        const RECORDS = Runtime.create_records()
        function __init__()
            Runtime.init_records!(RECORDS)
            Runtime.register_recorder($recordmodule)
            return
        end

        get_records() = RECORDS
        clear() = empty!(get_records())

        struct IsEnabledFunction <: Runtime.AbstractIsEnabledFunction
            isrecording::typeof(isrecording)
            get_logger::typeof(get_logger)
        end
        const isenabled = IsEnabledFunction(isrecording, get_logger)

        struct RecordFunction <: Runtime.AbstractRecordFunction
            defaultdata::DefaultDataFunction
            prefix::PrefixFunction
            isrecording::typeof(isrecording)
            get_logger::typeof(get_logger)
            get_records::typeof(get_records)
        end
        const record =
            RecordFunction(defaultdata, prefix, isrecording, get_logger, get_records)

        @doc $at_record_doc macro record(recordname, exprs...)
            $Runtime.record_impl(
                __source__,
                __module__,
                $recordmodule,
                recordname,
                collect(Any, exprs),
            )
        end

        end # module
    end

    return esc(Expr(:toplevel, expr.args...))
end

const RECORDERS = Module[]
register_recorder(recordmodule::Module) = push!(RECORDERS, recordmodule)

function as_kwarg_expr(x)
    if x isa Symbol
        return Expr(:kw, x, x)
    elseif isexpr(x, :(=), 2)
        return Expr(:kw, x.args...)
    else
        error("invalid expression: ", x)
    end
end

function record_impl(
    __source__::LineNumberNode,
    __module__::Module,
    recordmodule::Module,
    recordname,
    exprs,
)
    if isexpr(get(exprs, lastindex(exprs), nothing), :cury)
        options = map(as_kwarg_expr, exprs[end].args)
        exprs = exprs[begin:end-1]
    else
        options = []
    end
    data_kwargs = map(as_kwarg_expr, exprs)
    data = :((; $(data_kwargs...)))
    location = uuid4()
    quote
        if $recordmodule.isenabled()
            $recordmodule.record(
                $recordname,
                $data;
                location = $(QuoteNode(location)),
                __source__ = $(QuoteNode(__source__)),
                __module__ = $(QuoteNode(__module__)),
                $(options...),
            )
        end
    end |> esc
end

abstract type AbstractRecordFunction <: Function end
abstract type AbstractIsEnabledFunction <: Function end
abstract type AbstractDefaultDataFunction <: Function end
abstract type AbstractPrefixFunction <: Function end
abstract type AbstractIsRecordingFunction <: Function end

(::AbstractDefaultDataFunction)() = Historic.taskdata()
(::AbstractPrefixFunction)() = Historic.taskprefix()
(::AbstractIsRecordingFunction)() = false

function (record::AbstractRecordFunction)(
    name::Symbol,
    data::NamedTuple;
    yield::Bool = true,
    options...,
)
    logger = record.get_logger()
    islogging = logger !== nothing && should_log(options)
    if islogging && !yield && may_yield(logger)
        islogging = false
    end

    if record.isrecording()
        # Heuristics: `defaultdata` is shared across all records and it produces
        # the most "dense" column which is presumably the most informative one.
        # Putting it first so that they come first in the column tables.
        recorddata = (; record.defaultdata()..., data...)
        record!(record.get_records(), name, recorddata; options...)
    end

    if islogging
        # Heuristics: `defaultdata` is probably included in `prefix`. So, put it
        # at the end so that `DefaultLogger` prints the non-default data first.
        logdata = (; data..., record.defaultdata()...)
        logrecord(logger, name, logdata, record.prefix(); options...)
    end
end

(isenabled::AbstractIsEnabledFunction)() =
    isenabled.isrecording() || isenabled.get_logger() !== nothing

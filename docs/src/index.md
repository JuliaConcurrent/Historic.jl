# Historic.jl

## Defining recorder

```@docs
Historic.@define
Historic.Scratch
```

## Defining events

```@docs
Historic.Scratch.@record
```

### Tools for defining event data

```@docs
Historic.taskid
Historic.objid
Historic.uniqueid
```

## Recording events

!!! note
    `Historic.Scratch` is an example of the module defined by
    [`Historic.@define`](@ref).  If you define the recorder module using
    `Historic.@define YourRecorder`, Use, e.g., `YourRecorder.enable()` instead
    of `Historic.Scratch.enable()`.

```@docs
Historic.Scratch.enable
Historic.Scratch.enable_logging
Historic.clear
```

## Analyzing events

```@docs
Historic.events
Historic.flattable
```

See
[`lib/HistoricAnalysis`](https://github.com/JuliaConcurrent/Historic.jl/tree/main/lib/HistoricAnalysis)
as an example usage.

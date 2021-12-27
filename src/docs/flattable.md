    Historic.flattable() -> flattable
    Historic.flattable(recordmodule::Module) -> flattable
    Historic.flattable(eventtable) -> flattable

Return a flatten table of events; i.e., all custom event data key-value pairs
passed to `@record` can accessed as columns.

See also [`Historic.events`](@ref).

    Historic.@define RecordModule

Define a recorder module named `RecordModule` with a private event recording
buffer.

`RecordModule` has a macro [`RecordModule.@record(name, k₁ = v₁, …)`](@ref
Historic.Scratch.@record) that can be used for defining (a pice of code to emit)
events.  The recorder is disabled by default. It has to be enabled by
[`RecordModule.enable`](@ref Historic.Scratch.enable) at run-time.  Once the
recorder is enabled, the events are recorded whenever execution of the program
encounter the code path including `@record`.

`RecordModule` defines the following functions for manipulating recording:

* [`RecordModule.enable()`](@ref Historic.Scratch.enable) enables recording.
* [`RecordModule.disable()`](@ref Historic.Scratch.enable) disables recording.
* [`RecordModule.enable_logging()`](@ref Historic.Scratch.enable_logging)
  enables logging.
* [`RecordModule.disable_logging()`](@ref Historic.Scratch.enable_logging)
  disables logging.

`RecordModule` defines the following overloadable functions:

* `RecordModule.defaultdata()` returns a named tuple to be included in the
  event record by default.
* `RecordModule.prefix()` returns a string to be used asa prefix of the log
  message.
* `RecordModule.isrecording()` returns a `Bool` indicating if the events
  recorded by `RecordModule.@record` should be recorded by default.

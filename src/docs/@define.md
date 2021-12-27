    Historic.@define RecordModule

Define a module named `RecordModule` with a private event recording buffer.

* `RecordModule.@record(name, k₁ = v₁, …)`

`RecordModule` defines the following overloadable functions:

* `RecordModule.defaultdata()` returns a named tuple to be included in the
  event record by default.
* `RecordModule.prefix()` returns a string to be used asa prefix of the log
  message.
* `RecordModule.isrecording()` returns a `Bool` indicating if the events
  recorded by `RecordModule.@record` should be recorded by default.

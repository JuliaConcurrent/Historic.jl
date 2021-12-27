Historic.clear() = foreach(Historic.clear, RECORDERS)
Historic.clear(recordmodule::Module) = empty!(recordmodule.get_records()::EventRecord)
# TODO: recursive

Historic.recorders() = copy(RECORDERS)

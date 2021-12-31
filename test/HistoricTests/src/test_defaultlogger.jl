module TestDefaultlogger

using Historic.Internal: DefaultLogger
using Logging
using Test

function with_defaultlogger(body)
    buffer = (main = IOBuffer(), fallback = IOBuffer())
    context = (:displaysize => (5, 20),)
    io = (
        main = IOContext(buffer.main, context...),
        fallback = IOContext(buffer.fallback, context...),
    )
    logger = DefaultLogger(io.main, ConsoleLogger(io.fallback))
    ans = with_logger(body, logger)
    output = (main = String(take!(buffer.main)), fallback = String(take!(buffer.fallback)))
    return (; output, logger, io, buffer, ans)
end

function test()
    (; output) = with_defaultlogger() do
        @info(:msg1, a = 1, b = 2, c = 3)
        @info(:msg2, a = 1, very_very_very_very_very_very_long_key = 2)
        try
            error("an error to be caught")
        catch err
            @error(:msg3, a = 1, exception = (err, catch_backtrace()))
        end
    end
    @test output.main == """
        msg1 a=1 b=2 c=3
        msg2 a=1...
        Error: msg3 a=1
        """
    @test occursin("an error to be caught", output.fallback)
end

end  # module

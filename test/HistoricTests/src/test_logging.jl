module TestLogging

import Historic
using Logging
using Test

using ..Samples: Samples, Default

function with_logging(f, recordmodule, logger = true)
    if logger === true
        recordmodule.enable_logging()
    else
        recordmodule.set_logger(logger)
    end
    try
        Base.invokelatest(f)
    finally
        recordmodule.disable_logging()
    end
end

function test_default()
    Historic.clear(Default)
    logger = Test.TestLogger()
    with_logger(logger) do
        with_logging(Default) do
            Samples.default_simple()
            Samples.default_withdata(1)
            Samples.default_withdata(2)
        end
    end
    prefix = Historic.defaultprefix()
    @test logger.logs[1].message == "$(prefix)simple"
    @test logger.logs[2].message == "$(prefix)withdata"
    @test logger.logs[3].message == "$(prefix)withdata"
    return logger
end

end  # module

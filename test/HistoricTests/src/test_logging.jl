module TestLogging

import Historic
using Logging
using Test

using ..Samples: Samples, Default

function with_logging(f, recordmodule, logger = true)
    recordmodule.set_logger(logger)
    try
        Base.invokelatest(f)
    finally
        recordmodule.disable_logging()
    end
end

function test_default()
    Historic.clear(Default)
    main = Test.TestLogger()
    with_logging(Default, main) do
        Samples.default_simple()
        Samples.default_noyield()
        Samples.default_withdata(1)
        Samples.default_withdata(2)
        Samples.default_throw()
    end
    prefix = Historic.defaultprefix()
    @test main.logs[1].message == "$(prefix)simple"
    @test main.logs[2].message == "$(prefix)withdata"
    @test main.logs[3].message == "$(prefix)withdata"
    @test main.logs[3].message == "$(prefix)withdata"
    return main
end

end  # module

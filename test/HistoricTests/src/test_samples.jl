module TestSamples

import Historic
using Test

using ..Samples: Samples, Default, Custom

function test_default()
    Historic.clear(Default)
    Samples.default_simple()
    Samples.default_withdata(1)
    Samples.default_withdata(2)
    events = Historic.events(Default)
    @test events.name == [:simple, :withdata, :withdata]
    defaultdata = Historic.defaultdata()
    @test events.data == [defaultdata, (; defaultdata..., k = 1), (; defaultdata..., k = 2)]
    @test events.threadid == fill(Threads.threadid(), 3)
end

function test_custom()
    Historic.clear(Custom)
    Samples.custom_simple()
    Samples.custom_withdata(1)
    Samples.custom_withdata(2)
    events = Historic.events(Custom)
    @test events.name == [:simple, :withdata, :withdata]
    defaultdata = (; foo = :bar)
    @test events.data == [defaultdata, (; defaultdata..., k = 1), (; defaultdata..., k = 2)]
    @test events.threadid == fill(Threads.threadid(), 3)
end

end  # module

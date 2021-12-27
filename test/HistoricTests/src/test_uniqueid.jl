module TestUniqueID

import Historic
using Test

using ..Utils

function test_single_thread()
    ids = [Historic.uniqueid() for _ in 1:100]
    @test allunique(ids)
end

function test_multi_thread()
    outputs = [UInt64[] for _ in 1:Threads.nthreads()]
    Utils.foreachthread(outputs) do ids
        for _ in 1:1000
            push!(ids, Historic.uniqueid())
        end
    end
    ids = reduce(vcat, outputs)
    @test allunique(ids)
end

end  # module

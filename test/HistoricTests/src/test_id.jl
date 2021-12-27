module TestID

import Historic
using Test

function test_taskid()
    global task1 = @task nothing
    global task2 = @task nothing
    @test Historic.taskid(task1) === Historic.taskid(task1)
    @test Historic.taskid(task1) !== Historic.taskid(task2)
end

function test_objid()
    global ref1 = Ref(0)
    global ref2 = Ref(0)
    @test Historic.objid(ref1) === Historic.objid(ref1)
    @test Historic.objid(ref1) !== Historic.objid(ref2)
    @test Historic.objid(1) === Historic.objid(1)
end

end  # module

Historic.taskdata() = (taskid = Historic.taskid(),)

Historic.taskprefix() =
    sprint() do io
        if Threads.nthreads() > 1
            print(io, "thread:", Threads.threadid(), " ")
        end
        print(io, Historic.taskid())
        print(io, ' ')
    end

module Utils

function pause()
    ccall(:jl_cpu_pause, Cvoid, ())
    GC.safepoint()
end

"""
    foreachthread(f, xs)

Like `foreach(f, xs)` but run `f(x)` in its own thread and try to make different
invocations of `f` as "concurrent" as possible for testing race-related bugs.
"""
function foreachthread(f, xs)
    if length(xs) > Threads.nthreads()
        error(
            "length (=",
            length(xs),
            ") of the input vector must be smaller than or equal to nthread (=",
            Threads.nthreads(),
            ")",
        )
    end
    if Threads.nthreads() == 1
        foreach(f, xs)
        return
    end

    nactives = Threads.Atomic{Int}(length(xs))
    go = Threads.Atomic{Bool}(false)
    Threads.@threads for x in xs
        if Threads.atomic_sub!(nactives, 1) > 1
            go[] = true
        else
            for _ in 1:1000_000
                go[] && break
                pause()
            end
            if !go[]
                @error "Failed to wait for go signal (threadid: $(Threads.threadid()))"
            end
        end

        f(x)
    end
end

end  # module

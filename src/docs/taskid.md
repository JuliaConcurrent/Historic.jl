    Historic.taskid(task::Task = current_task())

Get a (pseudo) id for a `task`.

It does not uniquely identify a task (thus "pseudo") when the task is garbage
collected and the corresponding memory region is re-used.

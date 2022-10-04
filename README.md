# TT CPU Scheduler

Task Type (TT) is an alternative CPU Scheduler for linux.

The goal of the Task Type (TT) scheduler is to detect
tasks types based on their behaviours and control the schedulling
based on their types. There are 5 types:
1. REALTIME
2. INTERACTIVE
3. NO_TYPE
4. CPU_BOUND
5. BATCH

Find the descriptions and the detection rules in `tasks.ods`

The benefit of task types is to allow the scheduler to have
more control and choose the best task to run next in the CPU.

TT gives RT tasks a `-20` prio in vruntime calculations. This boosts RT
tasks over other tasks. The preemption rules are purely HRRN where RT tasks
have a priority since their vruntimes are relatively less than other types.
The reason of using HRRN instead of hard level picking is to smooth out the
preemtions and to prevent any chance of starvation.

## Monitoring detected tasks
You need to compile with `CONFIG_SCHED_DEBUG=y`. I have added a field in the
output of tasks information `task_type`. See and use `ttdebug.sh`.

Usage examples:

`ttdebug.sh | grep -i realtime`

`watch -t "(ttdebug.sh | grep -i interactive)"`

`watch -t "(ttdebug.sh | egrep -i 'webco|firefox')"`


Note: Tasks types are detected based on their behaviour, not by what it should
be. So if systemd at some point acted like a REALTIME tasks and went for long sleep
then the type would be REALTIME until it wakes up and get its type updated.
You might see many sleeping tasks with incorrect types
because at some point on booting time they acted like REALTIME, CPU_BOUND, or
whatever type. Those tasks are sleeping for long time, so when they wake up their
type will be INTERACITVE sine they have very hight HRRN value. So, don't worry
about the type of sleeping system processes.


## sysctl`s`
`kernel.sched_tt_max_lifetime`

Default is 22s. This is the tasks' maximum life time to normalize their life
time and vruntime. Similar to CacULE's `cacule_max_lifetime`.


`kernel.sched_tt_rt_prio`
Default is -20. Range [-20, 19]. In case that tasks with types other than realtime
are starving because of realtime tasks' priorities are too high, you can soften
the priority of realtime tasks. The -20 is the highest, 19 is the least priority.

`kernel.sched_tt_interactive_prio`
Default is -10. Range [-20, 19].

`kernel.sched_tt_cpu_bound_prio`
Default is -15. Range [-20, 19].

`kernel.sched_tt_batch_prio`
Default is 19. Range [-20, 19].


`kernel.sched_tt_balancer_opt`

It can be set to 4 values:

- 0: Normal TT balancer
- 1: Candidate Balancer (which is an addition to normal TT balancer - good for reponsiveness (perfomance gets affected when #CPUs > 4))
- 2: CFS balancer (default - good for perfomance/throughput)
- 3: Power save balancer (tries its best to avoid running tasks on idle cpus - saves power)

You can change the balancer option at run time.

`kernel.sched_tt_lat_sens_enabled`
Default is 1. latency sensitive keeps CPUs (with no tasks) at high frequency for sometime (~1ms) in
case of incoming task during this time would run faster. It reduces latency but increases power consumption.
If Power save balancer is chosen, then this option has no effect (i.e. disabled, = 0).

`kernel.sched_tt_dedicated_cpu_bound_enabled`
Default is 1. This option stick a CPU bound task to its current CPU to enhance cache locality.
A CPU can only have one dedicated cpu bound task.


## Support
Telegram: https://t.me/tt_sched

Thank you

Hamad

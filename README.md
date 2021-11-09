This is a testing version of TT cpu scheduler
---------------------------------------------


## Background
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
more control and choose the best task to run next in CPU.
Notice that the work is not done yet. I am planning to work on
load balancer, but before that I need to have good testing on
both task detection and task preemption rules before moving forward.

So far, on my machine, the scheduler had higher fps in glxgears during
compiling kernel. Even CFS with autogroup doesn't come close. The reason
is that glxgears are detected to be REALTIME task and compiling threads 
are detected to be CPU_BOUND and BATCH. In tasks.ods you can see that
rt is chosen to run in the CPU over all other tasks (it has high priority).

TT gives RT tasks a `-20` prio in vruntime calculations. This boosts RT
tasks over other tasks. The preemption rules are purely HRRN where RT tasks
have a priority since their vruntimes are relatively less than other types.
The reason of using HRRN instead of hard level picking is to smooth out the
preemtions and to prevent any chance of starvation.

TT must be responsive as CacULE (on my machine it has better responsiveness resutls).
Also TT is interactive where REALTIME tasks has a priority.


## Definitions
**Burst**: is the time the task spent in the CPU before it choose to sleep/exit
       the burst resets if the task slept/wait for IO or for timer interrupts.
       REALTIME tasks has relatively equal bursts.

**Wait**: There is total wait time which is used in HRRN calculation, and last two waits
      which are used to be relatively equal for REALTIME tasks. Waiting times
      for INTERACTIVE tasks must be not equal.


## Monitoring detected tasks
You need to compile with `CONFIG_SCHED_DEBUG=y`. I have added a field in the
output of tasks information `task_type`. See and use `ttdebug.sh`.

ttdebug.sh content:
```
cat /proc/[1-9]*/task/[1-9]*/sched 2>/dev/null | grep task_type -B2 | \
	perl -p -e 's/--*\n//g' | paste -sd " \n" | sed 's/ //g' | sed 's/task_type:/\t/'
```

Usage examples:

`ttdebug.sh | grep -i realtime`

`watch -t "(ttdebug.sh | grep -i interactive)"`

`watch -t "(ttdebug.sh | egrep -i 'webco|firefox')"`


## Testing
There are two Hz values that are added (833Hz and 1666Hz). You can try/ignore them.
Test the overall performance, latency, responsiveness. For example, compile
the kernel while running `vblank_mode=1 glxgears` and see how much frames it
became. Compare the results with other schedulers. See the overall responsiveness
under heavy load. Also you might check the tasks you are testing with `ttdebug.sh`
and if you think there is a miss-detected task/s then use below sysctls tunning.

Note: Tasks types are detected based on their behaviour, not by what you think
the type is! So if systemd at some point acted like a REALTIME tasks then the
type would be REALTIME. You might see many sleeping tasks with incorrect types
because at some point on booting time they acted like REALTIME, CPU_BOUND, or
whatever type. Those task are sleeping for long time, so when they wake up their
type will be INTERACITVE sine they have very hight HRRN value. So, don't worry
about the type of sleeping system processes.

## RT patch
You need to make sure you select `CONFIG_PREEMPT_RT=y`.

## sysctl
`kernel.sched_tt_max_lifetime`

Defaul is 22s. This is the tasks' maximum life time to normalize their life
time and vruntime. Similar to CacULE's `cacule_max_lifetime`.




## Future Plan:
* Add sysctl to soften RT task priority
* Change HRRN to IS (including sysctl tunning)
* Port Starving Factor to TT (including sysctl tunning)
* Add sub-kconfig option to TT for full tasks accounting/stats -> to allow clamp feature and fix pstat issues
* Separate patch for high values of HZ's
* Separate patch for RT


Thank you

Hamad

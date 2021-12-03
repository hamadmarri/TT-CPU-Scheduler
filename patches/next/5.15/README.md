# New in TT v0.3

- Fix the possibility of div. over zero in HRRN calculation.
- set sysctl `sched_tt_rt_prio` max from 39 to 19
- Added Candidate Balancer (only for `REALTIME` and `INTERACTIVE` tasks)
- Added latency sensitive patch (adjusted for TT work)
	- Issue (https://github.com/hamadmarri/TT-CPU-Scheduler/issues/8)
	- Only `INTERACTIVE` tasks which contribute to `nr_lat_sensitive`
	- Special case for `REALTIME` tasks when they dequeue for sleep,
	  if `avg. wait time <= next_tick_due`, then contribute to `nr_lat_sensitive`
	  (i.e. keep CPU active/not_idle if we have a realtime task that
	  would wakeup soon before or equal to the next tick)
	- decay `nr_lat_sensitive` by 1 every 4ms


# Goals
The interactivity would increase slightly with Candidate Balancer (CB) and
latency sensitive patches but with tiny performance cost.


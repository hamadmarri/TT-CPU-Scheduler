#!/usr/bin/bash

cat /proc/[1-9]*/task/[1-9]*/sched 2>/dev/null | grep task_type -B2 | \
	perl -p -e 's/--*\n//g' | paste -sd " \n" | sed 's/ //g' | sed 's/task_type:/\t/'


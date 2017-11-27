#!/bin/sh
# A script to log the cpu and memory usage of linux processes
# http://www.unix.com/shell-programming-and-scripting/223177-shell-script-logging-cpu-memory-usage-linux-process.html

#  TU Berlin --- Fachgebiet Regelungssystem
#  Author: Markus Valtin
#  Copyright © 2017 Markus Valtin. All rights reserved.
#
#  This program is free software: you can redistribute it and/or modify it under the terms of the 
#  GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

NAME_1=papi
NAME_2=AutoSearch
NAME_3=__none__

LOG_FILE=./workload.log


echo "Everything goes to $LOG_FILE ..."

#PID_1=$(ps -ef | grep kate | grep -v grep | awk '{print $2}')
#PID_2=$(ps -ef | grep chrom | grep -v grep | awk '{print $2}')

top -bc -d 1 | awk -v logfile=$LOG_FILE -v name1=$NAME_1 -v name2=$NAME_2 -v name3=$NAME_3 '
{
	if ($1 == "PID")
	{
		command="date +%s";
		command | getline ts
		close(command);
	}
	if ($12 ~ name1 || $12 ~ name2 || $12 ~ name3)
	{
		printf "%d  %d  %s  %s  %s\n",  ts,$1,$9,$10,$12>logfile
		fflush(logfile)
	}
}'

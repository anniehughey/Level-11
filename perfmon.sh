#!/bin/bash
# POLLINT and DURATION inputs must be non-negative integers or float values,
# PROCESS must be a string with length greated than 1. 

echo "Please enter a (1) process name, (2) poll incriment in seconds, and (3) a duration in minutes, 
	followed by [ENTER]:"
read PROCESS POLLINT DURATION

DURATION=$((DURATION*60)) 

if ! [[ $POLLINT =~ ^[0-9]+$ ]] || ! [[ $DURATION =~ ^[0-9]+$ ]]; then
	echo "Error: Poll Int (s) and Duration (m) must be integers."; exit
fi;

RUN_NUM=$(( $DURATION / $POLLINT ))

COUNTER=0
COUNTER1=1
CPU_ARRAY=()
MEM_ARRAY=()
VF_ARRAY=()
CPU_SUM=0
MEM_SUM=0
VF_SUM=0

while [[ $COUNTER -le $RUN_NUM ]] 
do

	CURRENT_CPU=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $9}')
	CURRENT_MEM=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $10}') 
	CURRENT_VF=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $5}')
	PROC_PID=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $1}')
			
	#CPU_ARRAY+=$CURRENT_CPU
	#MEM_ARRAY+=$CURRENT_CPU
	#VF_ARRAY+=$CURRENT_CPU
		
	CPU_SUM=$(echo "$CPU_SUM+$CURRENT_CPU" | bc -l)
	MEM_SUM=$(echo "$MEM_SUM+$CURRENT_MEM" | bc -l)
	VF_SUM=$(echo "$VF_SUM+$CURRENT_VF" | bc -l)

	echo "CPU SUM: $CPU_SUM MEM SUM: $MEM_SUM VF_SUM: $VF_SUM"

	#R_AVG_CPU=$(echo $CPU_SUM $COUNTER1 | awk '{printf "%4.3f\n",$1/$2}')
	#R_AVG_MEM=$(echo $MEM_SUM $COUNTER1 | awk '{printf "%4.3f\n",$1/$2}')
	#R_AVG_VF=$(echo $VF_SUM $COUNTER1 | awk '{printf "%4.3f\n",$1/$2}')

	R_AVG_CPU=$(echo "$CPU_SUM/$COUNTER1" | bc -l)
	R_AVG_MEM=$(echo "$MEM_SUM/$COUNTER1" | bc -l)
	R_AVG_VF=$(echo "$VF_SUM/$COUNTER1" | bc -l)
	
	#R_STD_CPU=
	#R_STD_MEM=
	#R_STD_VF=	

	echo "POLL NUMBER: $COUNTER1"
	echo "Process PID: $PROC_PID "
	echo "Current CPU: $CURRENT_CPU %"
	echo "Rolling AVG CPU: $R_AVG_CPU %"
	echo "Current MEM: $CURRENT_MEM %"
	echo "Rolling AVG MEM: $R_AVG_MEM %"
	echo "Current Virtual Footprint: $CURRENT_VF"
	echo "Rolling AVG Virtual Footprint: $R_AVG_VF " 
	
	sleep $POLLINT
	let COUNTER=COUNTER+1
	let COUNTER1=COUNTER1+1
done

if [[ $COUNTER -eq $RUN_NUM ]]; then 
	echo "Final CPU average: $R_AVG_CPU %"
	echo "Final Memory average: $R_AVG_MEM %"
	echo "Final Virtual Footprint average: $R_AVG_VF "
	echo "Final STD:   "
	echo "Trend Analysis"
fi

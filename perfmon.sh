#!/bin/bash
# POLLINT and DURATION inputs must be non-negative integers or float values,
# PROCESS must be a string with length greated than 1. 

PROCESS=$1
POLLINT=$2
MIN_DUR=$3
DURATION=$((DURATION*60)) 

if ! [[ $POLLINT =~ ^[0-9]+$ ]] || ! [[ $DURATION =~ ^[0-9]+$ ]]; then
	echo "Error: Poll Int (s) and Duration (m) must be integers or float values."; exit
fi;

if [ $# -eq 0 ]; then
	echo "Error: No arguments supplied, please enter a process argument to begin."; exit
fi;

RUN_NUM=$(( $DURATION / $POLLINT ))

START=0
i=$START
CPU_ARRAY=()
MEM_ARRAY=()
VF_ARRAY=()
CPU_SUM=0
MEM_SUM=0
VF_SUM=0
while [[ $i -le $RUN_NUM ]] 
do

#runs for as many pollint's in the duration time

	CURRENT_CPU=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $9}')
	CURRENT_MEM=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $10}') 
	CURRENT_VF=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $5}')
	PROC_PID=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $1}')	
	
	#CPU_ARRAY+=$CURRENT_CPU
	#MEM_ARRAY+=$CURRENT_CPU
	#VF_ARRAY+=$CURRENT_CPU
	
	CPU_SUM+=$CURRENT_CPU	
	MEM_SUM+=$CURRENT_MEM
	VF_SUM+=$CURRENT_VF 
	#if ! (( CPU_SUM == "0.0" )) ; then CPU_SUM=$( echo $CPU_SUM | sed 's/^0*//' )
	#elif ! (( MEM_SUM == "0.0" )) ; then MEM_SUM=$( echo $MEM_SUM | sed 's/^0*//' )
	#elif ! (( VF_SUM == "0.0" )) ; then VF_SUM=$( echo $VF_SUM | sed 's/^0*//' )
	#fi
	new_i=$(( i + 1 ))
	#if [ $CPU_SUM -eq 0 ] ; then R_AVG_CPU=0 ; else R_AVG_CPU="$(($CPU_SUM / $new_i))"
	#fi
	#if [ $MEM_SUM -eq 0 ] ; then R_AVG_MEM=0 ; else R_AVG_MEM="$(($MEM_SUM / $new_i))"
	#fi
	#if [ $VF_SUM -eq 0 ] ; then R_AVG_VF=0 ; else R_AVG_VF="$(($VF_SUM / $new_i))"
	#fi
	
	echo "Process PID: $PROC_PID "
	echo "Current CPU: $CURRENT_CPU %"
	#echo "Current AVG CPU: $R_AVG_CPU %"
	echo "Current MEM: $CURRENT_MEM %"
	#echo "Current AVG MEM: $R_AVG_MEM %"
	echo "Current Virtual Footprint: $CURRENT_VF %"
	#echo "Current AVG Virtual Footprint: $R_AVG_VF %"
	 

	let "$i += 1" 
	sleep $POLLINT
done



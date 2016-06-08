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
			
	CPU_ARRAY[$COUNTER]=($CURRENT_CPU)
	MEM_ARRAY[$COUNTER]=($CURRENT_MEM)
	VF_ARRAY[$COUNTER]=($CURRENT_VF)

	echo "CPU: $CPU_ARRAY   MEM: $MEM_ARRAY   VF: $VF_ARRAY"
		
	CPU_SUM=$(echo "$CPU_SUM+$CURRENT_CPU" | bc -l)
	MEM_SUM=$(echo "$MEM_SUM+$CURRENT_MEM" | bc -l)
	VF_SUM=$(echo "$VF_SUM+$CURRENT_VF" | bc -l)

	R_AVG_CPU=$(echo "$CPU_SUM/$COUNTER1" | bc -l)
	R_AVG_MEM=$(echo "$MEM_SUM/$COUNTER1" | bc -l)
	R_AVG_VF=$(echo "$VF_SUM/$COUNTER1" | bc -l)
	
	#R_STD_CPU=
	#R_STD_MEM=
	#R_STD_VF=	

	echo -e "\nPOLL NUMBER: $COUNTER1"
	echo "Process PID: $PROC_PID "
	echo -e "\nCurrent CPU: $CURRENT_CPU %"
	echo "Rolling AVG CPU: $R_AVG_CPU %"
	echo "Rolling STD CPU: $R_STD_CPU "
	echo -e "\nCurrent MEM: $CURRENT_MEM %"
	echo "Rolling AVG MEM: $R_AVG_MEM %"
	echo "Rolling STD MEM: $R_STD_MEM "
	echo -e "\nCurrent Virtual Footprint: $CURRENT_VF"
	echo "Rolling AVG Virtual Footprint: $R_AVG_VF " 
	echo "Rolling STD Virtual Footprint: $R_STD_VF "
	sleep $POLLINT
	let COUNTER=COUNTER+1
	let COUNTER1=COUNTER1+1
done

echo -e "$CPU_ARRAY\n$MEM_ARRAY\n$VF_ARRAY"
L_of_L=($CPU_ARRAY,$MEM_ARRAY,$VF_ARRAY)
diff_CPU=0
diff_MEM=0
diff_VF=0
for list in list of list; do
	for e in list:
		if list == CPU_ARRAY:
			diffCPU=list[e+1]-list[e]
		if list == MEM_ARRAY
			diff_MEM=list[e+1]-list[e]
		if list == VF_ARRAY
			diff_VF=list[e+1]-list[e]

echo -e "\n"	
echo "Final CPU average: $R_AVG_CPU %"
echo "Final Memory average: $R_AVG_MEM %"
echo "Final Virtual Footprint average: $R_AVG_VF "




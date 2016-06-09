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
declare -a CPU_ARRAY=()
declare -a MEM_ARRAY=()
declare -a VF_ARRAY=()
CPU_SUM=0
MEM_SUM=0
VF_SUM=0
CPU_C_M=0
MEM_C_M=0
VF_C_M=0
xy_sum=0
x2_sum=0
x_sum=0


while [[ $COUNTER -le $RUN_NUM ]] 
do

	#pulls values from top command
	CURRENT_CPU=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $9}')
	CURRENT_MEM=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $10}') 
	CURRENT_VF=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $5}')
	PROC_PID=$(top -b -n1 | grep $PROCESS | head -1 | awk '{print $1}')
	
	#establishes array to hold all values at each poll int		
	CPU_ARRAY[$COUNTER]=$CURRENT_CPU
	MEM_ARRAY[$COUNTER]=$CURRENT_MEM
	VF_ARRAY[$COUNTER]=$CURRENT_VF
	
	echo -e "\nCPU: ${CPU_ARRAY[@]}   MEM: ${MEM_ARRAY[@]}   VF: ${VF_ARRAY[@]}"
		
	CPU_SUM=$(echo "$CPU_SUM+$CURRENT_CPU" | bc -l)
	MEM_SUM=$(echo "$MEM_SUM+$CURRENT_MEM" | bc -l)
	VF_SUM=$(echo "$VF_SUM+$CURRENT_VF" | bc -l)

	R_AVG_CPU=$(echo "scale = 5; $CPU_SUM/$COUNTER1" | bc -l)
	R_AVG_MEM=$(echo "scale = 5; $MEM_SUM/$COUNTER1" | bc -l)
	R_AVG_VF=$(echo "scale = 5; $VF_SUM/$COUNTER1" | bc -l)
	
	x_sum=$(( x_sum + COUNTER))
	c_c=$(( COUNTER * COUNTER ))
	x2_sum=$(( x2_sum + c_c ))
	xy=$(echo "scale = 5; $x_sum*$CURRENT_VF" | bc -l)
	xy_sum=$(echo "scale = 5; $xy_sum+$xy" | bc -l)
		
	#finds the difference for STD calculations
	CPU_diff=$(echo "$CURRENT_CPU-$R_AVG_CPU" | bc -l)
	MEM_diff=$(echo "$CURRENT_MEM-$R_AVG_MEM" | bc -l)
	VF_diff=$(echo "$CURRENT_VF-$R_AVG_VF" | bc -l)

	#current minus mean STD calculations, then making all positive numbers
	CPU_C_M=$(echo "$CPU_C_M+$CPU_diff" | bc -l)
	CPU_C_M=$(echo "$CPU_C_M" | tr -d -)
	MEM_C_M=$(echo "$MEM_C_M+$MEM_diff" | bc -l)
	MEM_C_M=$(echo "$MEM_C_M" | tr -d -)
	VF_C_M=$(echo "$VF_C_M+$VF_diff" | bc -l)
	VF_C_M=$(echo "$VF_C_M" | tr -d -)

	R_STD_CPU=$(echo "scale = 5; sqrt($CPU_C_M / $COUNTER1)" | bc -l)
	R_STD_MEM=$(echo "scale = 5; sqrt($MEM_C_M / $COUNTER1)" | bc -l)
	R_STD_VF=$(echo "scale = 5; sqrt($VF_C_M / $COUNTER1)" | bc -l)	

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
y_sum=$VF_SUM
num=$COUNTER
mean_x=$(echo "scale = 5; $x_sum/$num" | bc -l)
mean_y=$(echo "scale = 5; $y_sum/$num" | bc -l)
mean_xy=$(echo "scale = 5; $xy_sum/$num" | bc -l)
mean_x2=$(echo "scale = 5; $x2_sum/$num" | bc -l)
mx_t_my=$(echo "scale = 5; $mean_x*$mean_y" | bc -l)
mxy_m=$(echo "scale = 5; $mean_xy-$mx_t_my" | bc -l)
mx2_m=$(echo "scale = 5; $mean_x2-$mx_t_my" | bc -l) 
slope=$(echo "scale = 5; $mxy_m/$mx2_m" | bc -l)

echo "$mxy_m"
echo "$mx2_m"
echo -e "\n"	
echo "Final CPU average: $R_AVG_CPU %"
echo "Final Memory average: $R_AVG_MEM %"
echo "Final Virtual Footprint average: $R_AVG_VF "
echo "Final CPU standard dev: $R_STD_CPU"
echo "Final Memory standard dev: $R_STD_MEM"
echo "Final VF standard dev: $R_STD_VF"
echo -e "\nVF SLOPE: $slope \n"

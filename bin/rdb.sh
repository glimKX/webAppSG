#!/bin/bash
##########################################################
# Script to run both of the RDB processes from the template
# RDB 1 will only subscribe to trade and quote 
# RDB 2 will only subscribe to aggreg
###########################################################

###########################################################
# Function: err
# Description: log error message
###########################################################
err()
{
	local TEXT=${1}
	printf "ERROR: %s\n" "${TEXT}"
	return 1
}
###########################################################
# Function: log
# Description: log message
###########################################################
info()
{
	local TEXT=${1}
	printf "INFO: %s\n" "${TEXT}"
	return 0
}
###########################################################
# Function: printLines
# Description: print Double Lines
###########################################################
printLines()
{
	printf "=======================================\n"
	return 0
}
###########################################################
#	if [ $# -eq 0 ]
#	then 
#		err "Missing Argument, choose which RDB to start"
#		exit 1
#	fi
#	if [[ $1 == "RDB1" ]]
#	then
cd $SCRIPTS_DIR
		info "Initialising RDB1 and subscribing to trade and quote"
		#$q tick/r.q :$TICK_PORT -table "trade;quote" -p $RDB1_PORT 
		($q tick/r.q :$TICK_PORT -table "trade;quote" -p $RDB1_PORT > /dev/null 2>&1 &)
		sleep 2
		if [[ ! -z $(ps -ef|grep $RDB1_PORT|grep r.q|grep -v bash) ]]
		then 
		info "RDB1 started on port $RDB1_PORT"
		else
		err "RDB1 failed to start"
		fi
#	fi
#	if [[ $1 == "RDB2" ]]
#	then 
		info "Initialising RDB2 and subscribing to aggregrate"
		($q tick/r.q :$TICK_PORT -table "aggreg" -p $RDB2_PORT > /dev/null 2>&1 &)
		sleep 2  
		if [[ ! -z $(ps -ef|grep $RDB2_PORT|grep r.q|grep -v bash) ]]
		then
		info "RDB2 started on port $RDB2_PORT"
		else
                err "RDB2 failed to start"
                fi
#	fi

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
		info "Initialising CENTRAL BACKEND Process"
		($q tick/backend.q -p $BACKEND_PORT > /dev/null 2>&1 &)
#		$q tick/backend.q -p $BACKEND_PORT
		sleep 2
		if [[ ! -z $(ps -ef|grep $BACKEND_PORT|grep backend.q|grep -v bash) ]]
		then 
		info "CENTRAL BACKEND Process started on port $BACKEND_PORT"
		else
		err "CENTRAL BACKEND Process failed to start"
		fi
#	fi

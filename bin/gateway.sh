#!/bin/bash
##########################################################
# Script to run HDB processes from the template
# HDB 1 will load all tables 
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
cd $SCRIPTS_DIR
info "Initialising GATEWAY"
#($q tick/gateway.q -p $GATEWAY_PORT -U $USERS > /dev/null 2>&1 &)
rlwrap -r $q tick/gateway.q -p $GATEWAY_PORT -U $USERS 
sleep 2
if [[ ! -z $(ps -ef|grep $GATEWAY_PORT|grep gateway.q|grep -v bash) ]]
then 
	info "GATEWAY started on port $GATEWAY_PORT"
else
	err "GATEWAY failed to start"
fi

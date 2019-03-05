#!/bin/bash
##########################################################
# Script to run cep processes from the template
# CEP (default)  will only subscribe to trade and quote and run aggregration function 
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
info "Initialising C4 Process and subscribing to Backend"
($q tick/c4.q -w 200 -p $C41_PORT > /dev/null 2>&1 &)
#rlwrap $q tick/c4.q -w 200 -p $C41_PORT
sleep 2
if [[ ! -z $(ps -ef|grep $C41_PORT |grep -v grep|grep -v bash) ]]
then 
	info "C41 started on port $C41_PORT"
else
	err "C41 failed to start"
fi

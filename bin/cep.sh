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
info "Initialising CEP and subscribing to trade and quote"
($q tick/cep.q :$TICK_PORT -func aggregration -p $CEP_PORT > /dev/null 2>&1 &)
#$q tick/cep.q :$TICK_PORT -func aggregration -p $CEP_PORT
sleep 2
if [[ ! -z $(ps -ef|grep $CEP_PORT |grep -v grep|grep -v bash) ]]
then 
	info "CEP started on port $CEP_PORT"
else
	err "CEP failed to start"
fi

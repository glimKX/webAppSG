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
info "Initialising TEST Process and subscribing to Backend"
($q tick/test.q -w 200 -p $TEST1_PORT > /dev/null 2>&1 &)
#rlwrap $q tick/test.q -p $TEST1_PORT
sleep 2
if [[ ! -z $(ps -ef|grep $TEST1_PORT |grep -v grep|grep -v bash) ]]
then 
	info "TEST1 started on port $TEST1_PORT"
else
	err "TEST1 failed to start"
fi

($q tick/test.q -w 200 -p $TEST2_PORT > /dev/null 2>&1 &)
sleep 2
if [[ ! -z $(ps -ef|grep $TEST2_PORT |grep -v grep|grep -v bash) ]]
then
        info "TEST2 started on port $TEST2_PORT"
else
        err "TEST2 failed to start"
fi

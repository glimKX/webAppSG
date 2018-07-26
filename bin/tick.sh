#!/bin/bash
##########################################################
# Script to run TickerPlant processes from the template
# TickerPlant starts with 5010 port
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
info "Initialising TickerPlant with predefined schemas"
cd $SCRIPTS_DIR
nohup $q tick.q tick/sym.q $TPLOG_DIR -p $TICK_PORT -t 1000 > /dev/null 2>&1 &
#$q tick.q tick/sym.q $TPLOG_DIR -p $TICK_PORT -t 1000 
sleep 2
if [[ ! -z $(ps -ef | grep $TICK_PORT | grep tick.q|grep -v bash) ]]
then
	info "TickerPlant started on port $1"
else
	err "TIckerPlant failed to start"	
fi

#!/bin/bash
##########################################################
# Script to run TickerPlant processes from the template
# TickerPlant starts with $TICK_PORT port
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
info "Initialising FeedHandler with predefined timer" 
nohup $q feed.q :$TICK_PORT -t 1000 -p $FEED_PORT > /dev/null 2>&1 &
sleep 2
if [[ ! -z $(ps -ef | grep $FEED_PORT | grep -v grep|grep -v bash) ]]
then
	info "FeedHandler started on port $FEED_PORT"
else
	err "FeedHandler failed to start"	
	exit 1
fi

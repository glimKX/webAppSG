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
info "Initialising DAIDI"
($q tick/daidi.q -p $DAIDI_PORT > /dev/null 2>&1 &)
#$q tick/daidi.q -p $DAIDI_PORT
sleep 2
if [[ ! -z $(ps -ef|grep $DAIDI_PORT|grep daidi.q|grep -v bash) ]]
then 
	info "DAIDI started on port $DAIDI_PORT"
else
	err "DAIDI failed to start"
fi

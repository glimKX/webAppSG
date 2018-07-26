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
info "Initialising HDB"
($q tick/hdb.q -p $HDB_PORT > /dev/null 2>&1 &)
sleep 2
if [[ ! -z $(ps -ef|grep $HDB_PORT|grep hdb.q|grep -v bash) ]]
then 
	info "HDB started on port $HDB_PORT"
else
	err "HDB failed to start"
fi

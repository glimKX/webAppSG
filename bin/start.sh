#!/bin/bash
##########################################################
# Script to stop all processes
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
# Function: warn 
# Description: warn message
###########################################################
warn()
{
        local TEXT=${1}
        printf "WARN: %s\n" "${TEXT}"
        return 0
}
###########################################################
# Function: printHeader
# Description: print Double Lines
###########################################################
printHeader()
{
	printf "=======================================\n"
	return 0
}
###########################################################
# Function: printLines 
# Description: print Single Lines 
###########################################################
printLines()
{
        printf "+-------------------------------------+\n"
        return 0
}
###########################################################
# Function: startTickerPlant
# Description: starts ticker plant
###########################################################
startTickerPlant()
{
	printLines
	info "Starting TickerPlant"
	printLines
       	info "Check for existing tickerPlant"
	if [[ -z $(ps -ef | grep "\.q" | grep tick.q|grep -v grep) ]]
	then
        	info "No Existing tickerPlant found"
        	info "Starting tickerPlant with port $TICK_PORT"
        	bash tick.sh 
	else
        	warn "Existing Tickerplant found, not starting tickerPlant"
	fi 
	return 0

}
###########################################################
# Function: startRDB
# Description: starts RDB
###########################################################
startBackend()
{
	printLines
	info "Starting Backend"
	printLines
	info "Check for existing Backend"
	if [[ -z $(ps -ef | grep "\.q" | grep backend.q|grep -v grep) ]]
	then
        	info "No Existing Backend found"
        	info "Starting Backend"
        	bash backend.sh 
	else
       		warn "Existing Backend found, not starting Backend"
	fi
	return 0
}
###########################################################
# Function: startFeed
# Description: starts FeedHandler
###########################################################
startFeed()
{
        printLines
	info "Starting FeedHandler"
	printLines
	info "Check for existing feedHandler"
	if [[ -z $(ps -ef | grep "\.q" | grep feed.q|grep -v grep) ]]
	then
        	info "No Existing FeedHandler found"
        	info "Starting FeedHandler"
        	bash feed.sh 
	else
        	warn "Existing FeedHandler found, not starting FeedHandler"
	fi
        return 0
}
###########################################################
# Function: startCEP
# Description: starts CEP
###########################################################
startCEP()
{
        printLines
        info "Starting CEP"
        printLines
        info "Check for existing CEP"
        if [[ -z $(ps -ef | grep "\.q" | grep cep.q|grep -v grep) ]]
        then
                info "No Existing CEP found"
                info "Starting CEP"
                bash cep.sh 
        else
                warn "Existing CEP found, not starting CEP"
        fi
        return 0
}
###########################################################
# Function: startHDB
# Description: starts HDB
###########################################################
startHDB()
{
        printLines
        info "Starting HDB"
        printLines
        info "Check for existing HDB"
        if [[ -z $(ps -ef | grep "\.q" | grep hdb.q|grep -v grep) ]]
        then
                info "No Existing HDB found"
                info "Starting HDB"
                bash hdb.sh  
        else
                warn "Existing HDB found, not starting HDB"
        fi
        return 0
}
###########################################################
# Function: startGateway
# Description: starts Gateway
###########################################################
startGateway()
{
        printLines
        info "Starting GATEWAY"
        printLines
        info "Check for existing GATEWAY"
        if [[ -z $(ps -ef | grep "\.q" | grep gateway.q|grep -v grep) ]]
        then
                info "No Existing Gateway found"
                info "Starting Gateway"
                bash gateway.sh
        else
                warn "Existing Gateway found, not starting Gateway"
        fi
        return 0
}
###########################################################
# Function: sourceQ 
# Description: source for Q 
###########################################################
sourceQ()
{
	printLines
	info "Sourcing for q"
	printLines
	export q=$(find ~ -name q | grep l[6432])
	if [[ ! -z "$q" ]]
	then
        	info "Found q app $q"
	else
		err "q app cannot be found, unable to start"
		exit 1
	fi
}
###########################################################
# Function: sourceConfig 
# Description: source for Config 
###########################################################
sourceConfig()
{
        printLines
        info "Sourcing for Config"
        printLines
	if [ ! -f ../config/port.config ]
	then 
		err "config file is missing"
		exit 1
	else
		source ../config/port.config
		info "Sourced for config"	
	fi
	if [ ! -f ../config/env.config ]
	then
		err "Env file is missing"
		exit 1
	else
		source ../config/env.config
		info "Sourced for Environments"
	fi
}
###########################################################
printHeader
if [ "$1" = "ALL" ] || [ $# -eq 0 ]
then
	info "Starting ALL q processes for TickerPlant"
	sourceQ
	sourceConfig
	startBackend
	startGateway
	info "Finish Starting ALL"
elif [ "$1" = "tickerplant" ]
then
	info "Starting TickerPlant Only"
	sourceQ
	sourceConfig
	startTickerPlant
	info "Finish Starting TickerPlant"
elif [ "$1" = "backend" ]
then
	info "Starting Backend Only"
	sourceQ
	sourceConfig
	startBackend
	info "Finish Starting RDB"
elif [ "$1" = "feed" ]
then
	info "Starting FeedHandler Only"
	sourceQ
	sourceConfig
	startFeed
	info "Finish Starting FeedHandler"
elif [ "$1" = "cep" ]
then
        info "Starting CEP Only"
        sourceQ
	sourceConfig
        startCEP
        info "Finish Starting CEP"
elif [ "$1" = "hdb" ] 
then
        info "Starting HDB Only"
        sourceQ
        sourceConfig
        startHDB
        info "Finish Starting HDB"
elif [ "$1" = "gateway" ]
then
	info "Starting Gateway Only"
	sourceQ
	sourceConfig
	startGateway
	info "Finish Starting Gateway"
fi
printHeader
exit 0 

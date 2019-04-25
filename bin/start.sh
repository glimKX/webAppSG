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
# Function: startBackend
# Description: starts Backend
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
# Function: startDaidi
# Description: starts Daidi
###########################################################
startDaidi()
{
        printLines
	info "Starting Daidi"
	printLines
	info "Check for existing Daidi"
	if [[ -z $(ps -ef | grep "\.q" | grep daidi.q|grep -v grep) ]]
	then
        	info "No Existing Daidi found"
        	info "Starting Daidi"
        	bash daidi.sh 
	else
        	warn "Existing Daidi found, not starting Daidi"
	fi
        return 0
}
###########################################################
# Function: startTest
# Description: starts Test
###########################################################
startTest()
{
        printLines
        info "Starting Test"
        printLines
        info "Check for existing Test"
        if [[ -z $(ps -ef | grep "\.q" | grep test.q|grep -v grep) ]]
        then
                info "No Existing Test found"
                info "Starting Test"
                bash test.sh 
        else
                warn "Existing Test found, not starting Test"
        fi
        return 0
}
###########################################################
# Function: startC4
# Description: starts C4
###########################################################
startC4()
{
        printLines
        info "Starting C4"
        printLines
        info "Check for existing C4"
        if [[ -z $(ps -ef | grep "\.q" | grep c4.q|grep -v grep|grep -v vi) ]]
        then
                info "No Existing C4 found"
                info "Starting C4"
                bash c4.sh  
        else
                warn "Existing HDB found, not starting C4"
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
	startTest
	startC4
	startDaidi
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
	info "Finish Starting Backend"
elif [ "$1" = "daidi" ]
then
	info "Starting Daidi Only"
	sourceQ
	sourceConfig
	startDaidi
	info "Finish Starting FeedHandler"
elif [ "$1" = "test" ]
then
        info "Starting Test Only"
        sourceQ
	sourceConfig
        startTest
        info "Finish Starting Test"
elif [ "$1" = "c4" ] 
then
        info "Starting C4 Only"
        sourceQ
        sourceConfig
        startC4
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

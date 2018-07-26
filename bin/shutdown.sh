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
# Function: printLines
# Description: print Double Lines
###########################################################
printLines()
{
	printf "+-------------------------------------+\n"
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
# Function: shutdownAll
# Description: shutdown all q processes
###########################################################
shutdownAll()
{
		printLines
		info "Shutting down all running q"
		printLines
		info "Check for running q processes"
		runningQ=$(ps -ef | grep "\.q"| grep -v grep)  
		if [[ -z "$runningQ" ]]
		then 
			info "No running q process found" 
			info "Shutdown not required"
			exit 0 
		else
			info "Found running q processes"
			for PID in $(ps -ef | grep "\.q" | grep -v grep | awk '{print $2}')
			do
				info "Shutting down [$PID]"
				ps -ef | grep -w $PID | grep -v grep	
				kill $PID	
			done
		fi
		return 0
}
###########################################################
# Function: shutdownTick
# Description: shutdown Ticker PLant
###########################################################
shutdownTick()
{
        printLines
        info "Shutting down TickerPlant Only"
        printLines
        info "Check for running TickerPlant"
        if [[ -z $(ps -ef | grep "\.q" | grep tick.q|grep -v grep) ]]
        then
			info "No running q process found"
	        info "Shutdown not required"
        	exit 0
        else
			info "Found running q processes"
	        for PID in $(ps -ef | grep "\.q" | grep tick.q|grep -v grep | awk '{print $2}')
			do
				info "Shutting down [$PID]"
				ps -ef | grep -w $PID | grep -v grep
				kill $PID
			done
        fi
        return 0
}
###########################################################
# Function: shutdownRDB
# Description: shutdown RDB
###########################################################
shutdownRDB()
{
        printLines
        info "Shutting down RDB Only"
        printLines
        info "Check for running RDB"
        if [[ -z $(ps -ef | grep "\.q" | grep r.q|grep -v grep) ]]
        then
			info "No running q process found"
	        info "Shutdown not required"
        	exit 0
        else
			info "Found running q processes"
	        for PID in $(ps -ef | grep "\.q" | grep r.q|grep -v grep | awk '{print $2}')
			do
				info "Shutting down [$PID]"
				ps -ef | grep -w $PID | grep -v grep
				kill $PID
			done
        fi
        return 0
}
###########################################################
# Function: shutdownFeed
# Description: shutdown FeedHandler
###########################################################
shutdownFeed()
{
        printLines
        info "Shutting down FeedHandler Only"
        printLines
        info "Check for running FeedHandler"
        if [[ -z $(ps -ef | grep "\.q" | grep feed.q|grep -v grep) ]]
        then
		info "No running q process found"
	        info "Shutdown not required"
        	exit 0
        else
			info "Found running q processes"
	        for PID in $(ps -ef | grep "\.q" | grep feed.q|grep -v grep | awk '{print $2}')
			do
				info "Shutting down [$PID]"
				ps -ef | grep -w $PID | grep -v grep 
				kill $PID
			done
        fi
        return 0
}
###########################################################
# Function: shutdown CEP
# Description: shutdown CEP 
###########################################################
shutdownCEP()
{
        printLines
        info "Shutting down CEP Only"
        printLines
        info "Check for running CEP"
        if [[ -z $(ps -ef | grep "\.q" | grep cep.q|grep -v grep) ]]
        then
                info "No running q process found"
                info "Shutdown not required"
                exit 0
        else
                info "Found running q processes"
                for PID in $(ps -ef | grep "\.q" | grep cep.q|grep -v grep | awk '{print $2}')
                        do
                                info "Shutting down [$PID]" 
                                ps -ef | grep -w $PID | grep -v grep 
                                kill $PID
                        done
        fi
        return 0
}
###########################################################
# Function: shutdownHDB 
# Description: shutdown HDB 
###########################################################
shutdownHDB()
{
        printLines
        info "Shutting down HDB Only"
        printLines
        info "Check for running HDB"
        if [[ -z $(ps -ef | grep "\.q" | grep hdb.q|grep -v grep) ]]
        then
                info "No running q process found"
                info "Shutdown not required"
                exit 0
        else
                info "Found running q processes"
                for PID in $(ps -ef | grep "\.q" | grep hdb.q|grep -v grep | awk '{print $2}')
                        do
                                info "Shutting down [$PID]" 
                                ps -ef | grep -w $PID | grep -v grep 
                                kill $PID
                        done
        fi
}
###########################################################
# Function: shutdownGateway
# Description: shutdown Gateway
###########################################################
shutdownGateway()
{
	printLines
        info "Shutting down Gateway Only"
        printLines
        info "Check for running Gateway"
        if [[ -z $(ps -ef | grep "\.q" | grep gateway.q|grep -v grep) ]]
        then
                info "No running q process found"
                info "Shutdown not required"
                exit 0
        else
                info "Found running q processes"
                for PID in $(ps -ef | grep "\.q" | grep gateway.q|grep -v grep | awk '{print $2}')
                do
																		                                info "Shutting down [$PID]"
                         ps -ef | grep -w $PID | grep -v grep
                         kill $PID
                done																	        fi
}
###########################################################
printHeader
if [ "$1" = "ALL" ] || [ $# -eq 0 ]
then
        shutdownAll
        info "Finish Shutdown ALL"
elif [ "$1" = "tickerplant" ]
then
        shutdownTick
        info "Finish Shutdown TickerPlant"
elif [ "$1" = "rdb" ]
then
        shutdownRDB
        info "Finish Shutdown RDB"
elif [ "$1" = "feed" ]
then
        shutdownFeed
        info "Finish Shutdown FeedHandler"
elif [ "$1" = "cep" ]
then
        shutdownCEP
        info "Finish Shutdown CEP"
elif [ "$1" = "hdb" ] 
then
        shutdownHDB
        info "Finish Shutdown HDB"
elif [ "$1" = "gateway" ]
then
	shutdownGateway
        info "Finish Shutdown Gateway"
fi
printHeader
exit 0

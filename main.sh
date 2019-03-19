#!/bin/bash
##########################################################
# Script to check all processes
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
# Function: choices 
# Description: print choices
###########################################################
printChoices()
{
        printf "These are the followings choices for start mode\n	1.	ALL\n	2.	tickerplant\n	3.	backend\n	4.	feed\n	5.	test\n	6.	c4\n	7.	gateway\n"
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
        export q=$(find ~ -name q | grep l32)
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
        if [ ! -f config/port.config ]
        then
                err "config file is missing"
                exit 1
        else
                source config/port.config
                info "Sourced for config"
        fi
        if [ ! -f config/env.config ]
        then
                err "Env file is missing"
                exit 1
        else
                source config/env.config
                info "Sourced for Environments"
        fi
}
###########################################################

clear
printHeader
printf "Main Script for TickerPlant\n"
printHeader
printf "Script has 3 modes\n	1. Start:		To start processes\n	2. Shutdown:		To stop processes\n	3. Test:		To check on processes\n	4. LoadCSV:		To load csv into TickerPlant\n	5. reIngestTPLog:	To parse for IBM entries\n	6. TPLogToHDB:		To create compressed HDB\n	7. changeConfig:	To change config ports\n"
read -p 'Please input mode choice: ' choice
printf "Choice is: %s \n" "$choice"
printLines
if [ "$choice" = "Start" ] || [ "$choice" = "1" ]
then
	echo "Start Mode"
	cd bin
	printLines
	printChoices
	read -p 'Please input start mode choice: ' mode
	case "$mode" in
	ALL|1)
	./start.sh ALL
	;;
	tickerplant|2)
	./start.sh tickerplant
	;;
	backend|3)
	./start.sh backend
	;;
	feed|4)
	./start.sh feed
	;;
	test|5)
	./start.sh test
	;;
	c4|6)
	./start.sh c4
	;;
	gateway|7)
	./start.sh gateway
	;;
	*)
	err "No such choice exiting script"
	exit 1
	;;
	esac
elif [ "$choice" = "Shutdown" ] || [ "$choice" = "2" ]
then
	echo "Shutdown Mode"
	cd bin
	printLines
	printChoices
	read -p 'Please input shutdown mode choice: ' mode
	case "$mode" in
	'ALL'|'1')
	./shutdown.sh ALL
	;;
	'tickerplant'|'2')
	./shutdown.sh tickerplant
	;;
	'backend'|'3')
	./shutdown.sh backend 
	;;
	'feed'|'4')
	./shutdown.sh feed
	;;
	'test'|'5')
	./shutdown.sh test
	;;
	'c4'|'6')
        ./shutdown.sh c4 
        ;;
	'gateway'|'7')
	./shutdown.sh gateway
	;;
	*)
	err "No such choice exiting script"
	exit 1
	;;
	esac
elif [ "$choice" = "Test" ] || [ "$choice" = "3" ]
then
	echo "Test Mode"
	printLines
	info "Checking for running processes"
	echo "QPROCESS	PID	STIME	ARGUMENTS				PORT"
#glim     31516 13606  0 01:51 pts/3    00:00:00 /home/glim/q/l32/q tick.q sym tplog -p 5010 -t 1000
#glim     31681 13606  0 02:05 pts/3    00:00:00 /home/glim/q/l32/q tick/r.q :5010 -table trade;quote  5011
	ps -ef | grep "\.q" | grep -v grep | grep tick.q | awk '{printf ("%-8s\t%5s\t%4s\t%4s\t%-15s\t%4s\t\n",$9, $2, $5, "-tpDir", $11, $13)}'
	ps -ef | grep "\.q" | grep -v grep | grep -v tick.q | awk -F"-p" -v OFS='\t' '{print $1,$2}' | awk {'printf ("%-8s\t%5s\t%4s\t%4s\t%-15s\t\t\t%4s\t\n",$9, $2, $5, $11, $12, $NF)'}
	exit 0
elif [ "$choice" = "LoadCSV" ] || [ "$choice" = "4" ]
then
	echo "Load CSV Mode"
	printLines
	printf "CSV Mode has 3 modes to push to tickerPlant\n	1.	q\n	2.	c (api)\n	3.	python (api)\n"
	read -p 'Please input mode: ' csvMode
	if [ "$csvMode" = "q" ] || [ "$csvMode" = "1" ]
	then
		info "q mode"
		read -p 'Please input csvPath: ' csvInput
		info "Checking for running tickerplant"
		runStatus=$(ps -ef | grep "\.q" | grep -v grep | grep tick.q | awk '{print $13}')
		if [[ -z $runStatus ]]
		then 
			err "Tickerplant is not up, unable to push csv"
			exit 1
		else
			sourceQ
			sourceConfig
			info "Pushing csv to tickerplant"
			printf "\n"
			$q $SCRIPTS_DIR/csvLoad.q :$runStatus -csv $csvInput
		fi
	elif [ "$csvMode" = "c" ] || [ "$csvMode" = "2" ]
	then
		info "c mode"
		info "Checking for running tickerplant"
                runStatus=$(ps -ef | grep "\.q" | grep -v grep | grep tick.q | awk '{print $13}')
		if [[ -z $runStatus ]]
		then
			err "Tickerplant is not up, unable to push csv"
                        exit 1
		else
			sourceConfig
			info "Starting c api to push to tickerplant"
			$C_API_DIR/a.out
			printf "\n"
		fi
	elif [ "$csvMode" = "python" ] || [ "$csvMode" = "3" ]
        then
                info "python mode"
        fi
elif [ "$choice" = "reIngestTPLog" ] || [ "$choice" = "5" ]
then
	echo "reIngestTPLog Mode"
	printLines
	sourceQ
	sourceConfig
	printf "These are the available tplogs in $TPLOG_DIR \n"
	ls $TPLOG_DIR
	read -p 'Please input tpFile name (do not input path): ' tpInput
	info "Creating new tplogFile for $tpInput"
	printf "\n"
	$q $SCRIPTS_DIR/tplogIBM.q -tplogFile $tpInput
elif [ "$choice" = "TPLogToHDB" ] || [ "$choice" = "6" ]
then
        echo "TPLogToHDB Mode"
        printLines
        sourceQ
        sourceConfig
	printf "These are the available tplogs in $TPLOG_DIR \n" 
	ls $TPLOG_DIR
        read -p 'Please input tpFile name (do not input path): ' tpInput
        info "Creating compressed HDB for $tpInput"
        printf "\n"
        $q $SCRIPTS_DIR/compressHDB.q -tplogFile $tpInput	
elif [ "$choice" = "changeConfig" ] || [ "$choice" = "7" ]
then
	echo "changeConfig Mode"
	printLines
	if [ -f config/port.config ]
	then
		info "Opening text editor to config/port.config"
		vi config/port.config	
	else
		err "config/port.config is missing"
	fi
else
	err "Mode is not present exiting script"
	printLines
	exit 1
fi

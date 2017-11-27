#!/bin/bash
# Simulink StartScript: starts the specified Simulink program as well as PaPI and saves logs and *.mat files
# Version: 2; Date: 2017.06; Author: Markus Valtin

#  TU Berlin --- Fachgebiet Regelungssystem
#  Author: Markus Valtin
#  Copyright © 2017 Markus Valtin. All rights reserved.
#
#  This program is free software: you can redistribute it and/or modify it under the terms of the 
#  GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

# script config
##############################################################################################################

# which program do you want to start?
SIMULINK_EXE='./TODO->EXE_NAME_HERE'

# which command starts PaPI?
PAPI_EXE='papi'
# which PaPI config to use? You can leave it empty.
PAPI_CONFIG=''
# Close all PaPI windows?
KILL_PAPI_ON_EXIT=0;

# MAT data prefix? Which prefix have the *.mat files?
# Use a '*' to move all *.mat files. Leave it empty if you want to disable moving *.mat files.
MAT_FILE_PREFIX='EXP_*'

# include the executabel name in the filenames? 1 or 0
INCLUDE_EXEC_NAME=1

# Delay until start PaPI
PAPI_DELAY=2


# To which directory do you want to move the *.mat files?
DATA_DIR='data'
# To which directory do you want to move the log files?
LOG_DIR='logs'

# Log file names
SIMULINK_LOG_NAME='SimulinkExecLog'
PAPI_LOG_NAME='PaPILog'

# Format used by the date command, used for the file name pattern
DATE_FORMAT='+%Y.%m.%d'

# Directory to change to first. Leave it empty to disable this feature!
WORKING_DIRECTORY=''

# Directory where the *.mat files are saved
MAT_FILE_DIRECTORY='./'

# Wait on exit? 0 or 1 -> Only usefull if the script is started from a GUI eg. konsole -e thisScript.sh
WAIT_ON_EXIT=0;

## script start
##############################################################################################################
# changes after this point are normally not necessary
##############################################################################################################

# check the input arguments
SHOW_USAGE=0
SHOW_EXEC=0

# no arguments -> use defaults
USER_PREFIX=''

#one argument -> is it the executable name? -> check if executable exists
if [ "$#" -eq 1 ]; then # 1 argument
    if [ -x "$1" ]; then
        # the executable was found -> use the name as executable
        SIMULINK_EXE="$1"
    else
        # the executable was not found -> the argument must be the USER_PREFIX
        USER_PREFIX="$1"'_'
    fi
fi

#two arguments -> fist the executable name and second the USER_PREFIX -> checks are done later
if [ "$#" -eq 2 ]; then # 2 arguments
    SIMULINK_EXE="$1"
    USER_PREFIX="$2"'_'
fi

# three or more arguments -> show usage
if [ "$#" -ge 3 ]; then # 3 or more arguments
    SHOW_USAGE=1
fi


# check if executable exists
if [ ! -x "$SIMULINK_EXE" ]; then
    SHOW_USAGE=1
    SHOW_EXEC=1
fi

if [ "$SHOW_USAGE" -eq 1 ]; then #requires 1 arguments 
    echo "SIMULINK EXEC START SCRIPT"
    echo "=========================="
    echo ""
    echo "This script starts PaPI and the Simulink executable './$SIMULINK_EXE', creates log files and"
    echo "moves all '$MAT_FILE_DIRECTORY$MAT_FILE_PREFIX.mat' files into the data directory ('./$DATA_DIR') directory."
    echo "The files will get a prefix consisting of the DATE, the EXECUTABLE_NAME, the USER_PREFIX argument and a COUNTER."
    echo ""
    echo "USAGE: $(basename $0)  EXECUTABLE_NAME  USER_PREFIX"
    echo "====="
    echo "OR configure this script to your needs at the top of the script. See "
    echo "https://ti1.control.tu-berlin.de/redmine/projects/matlab-tools/wiki/Toolchain_StartScript"
    echo ""

    # show the exectable missing message?
    if [ "$SHOW_EXEC" -eq 1 ]; then
        echo "ERROR:"
        echo "======"
        echo " -> Simulink executable '$SIMULINK_EXE' was not found!"
        echo ""
    fi

    exit 1
fi


###########

# change to the working directory
if [ ! -z "$WORKING_DIRECTORY" ]; then
    echo -e "\n### Changing directory to $WORKING_DIRECTORY"
    cd "$WORKING_DIRECTORY"
fi

# make sure the executable name has "./"
if [[ "$SIMULINK_EXE" != *"/"* ]]; then
    # the string "/" is not in the string -> add it
    SIMULINK_EXE='./'"$SIMULINK_EXE"
fi

# check that the directories exist
if [ ! -d ${DATA_DIR} ]; then
    mkdir ${DATA_DIR}
fi 
if [ ! -d ${LOG_DIR} ]; then
    mkdir ${LOG_DIR}
fi

# generate the filenames
date_time=$(date "$DATE_FORMAT")
# add exec name?
if [ "$INCLUDE_EXEC_NAME" -eq 1 ]; then
    prefix_simulink_name=$(basename $SIMULINK_EXE)
else
    prefix_simulink_name=''
fi



# find a counter for which no filename exists yet
for i in '01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23' '24' '25' '26' '27' '28' '29' '30' '31' '32' '33' '34' '35' '36' '37' '38' '39' '41' '42' '43' '44' '45' '46' '47' '48' '49' '50' 
do

    if [ "$i" -eq "50" ]; then
        echo ""
        echo "Running out of unquiet IDs for log files and data -> Aborting! Maybe change the PREFIX."
        echo ""
        exit 1
    fi

    prefix="$date_time"'_'"$prefix_simulink_name"'_'"$USER_PREFIX""${i}"'__'
    if [ ! -f ${LOG_DIR}/${prefix}${SIMULINK_LOG_NAME}'.log' ]; then
        #echo "Counter found (${i}) -> prefix = ${prefix}"
        break
    fi
done

## create a default PaPI configuration
##############################################################################################################
cat <<EOF > .PaPI_StartConfigSimulinkController.xml
<PaPI Date="2016-09-01 00:00:00" PaPI_version="1.4.0"><Plugins><Plugin uname="UDPPlugin"><Identifier>UDP_Plugin</Identifier><StartConfig><Parameter Name="source_port"><value>20000</value></Parameter><Parameter Name="UseSocketIO"><value>0</value></Parameter><Parameter Name="SendOnReceivePort"><value>0</value></Parameter><Parameter Name="socketio_port"><value>8091</value></Parameter><Parameter Name="address"><value>127.0.0.1</value></Parameter><Parameter Name="OnlyInitialConfig"><value>0</value></Parameter><Parameter Name="out_port"><value>20001</value></Parameter></StartConfig><PreviousParameters><Parameter Name="consoleIn" /></PreviousParameters><DBlocks><DBlock Name="ConsoleSignals"><DSignal uname="MainSignal"><dname>MainSignal</dname></DSignal></DBlock><DBlock Name="ControllerSignals"><DSignal uname="ControlSignalReset"><dname>ControlSignalReset</dname></DSignal><DSignal uname="ControlSignalCreate"><dname>ControlSignalCreate</dname></DSignal><DSignal uname="ControlSignalSub"><dname>ControlSignalSub</dname></DSignal><DSignal uname="ControllerSignalParameter"><dname>ControllerSignalParameter</dname></DSignal><DSignal uname="ControllerSignalClose"><dname>ControllerSignalClose</dname></DSignal><DSignal uname="ActiveTab"><dname>ActiveTab</dname></DSignal></DBlock></DBlocks></Plugin><Plugin uname="PaPIController"><Identifier>PaPIController</Identifier><StartConfig><Parameter Name="name"><value>PaPIController</value></Parameter><Parameter Name="tab"><value>PaPI-Tab</value></Parameter><Parameter Name="size"><value>(150,75)</value></Parameter><Parameter Name="3:out_port"><value>20001</value></Parameter><Parameter Name="position"><value>(0,0)</value></Parameter><Parameter Name="uname"><value>PaPIController</value></Parameter><Parameter Name="maximized"><value>0</value></Parameter><Parameter Name="UseSocketIO"><value>0</value></Parameter><Parameter Name="SendOnReceivePort"><value>0</value></Parameter><Parameter Name="socketio_port"><value>8091</value></Parameter><Parameter Name="1:address"><value>127.0.0.1</value></Parameter><Parameter Name="UDP_Plugin_uname"><value>UDPPlugin</value></Parameter><Parameter Name="OnlyInitialConfig"><value>0</value></Parameter><Parameter Name="2:source_port"><value>20000</value></Parameter></StartConfig><PreviousParameters /><DBlocks /></Plugin></Plugins><Subscriptions><Subscription><Destination>PaPIController</Destination><Source uname="UDPPlugin"><Block name="ControllerSignals"><Alias /><Signals><Signal>ControlSignalReset</Signal><Signal>ControlSignalCreate</Signal><Signal>ControlSignalSub</Signal><Signal>ControllerSignalParameter</Signal><Signal>ControllerSignalClose</Signal><Signal>ActiveTab</Signal></Signals></Block></Source></Subscription></Subscriptions></PaPI>
EOF

## start PaPI
##############################################################################################################
DATE=$(date)
# call sudo, so that the authentication is stored and the PaPI start delay works
temp=$(sudo ls)

if [ -n "$PAPI_EXE" ]; then
    if [ -n "$PAPI_CONFIG" ]; then
        # start papi with a configuration parallel to the executable
        (
            echo "$BASHPID" > .papi.pid
            sleep $PAPI_DELAY
            echo -en "### Starting PaPI .....\nSimulink Program: $SIMULINK_EXE\nDate: $DATE\nConfig: $PAPI_CONFIG\n\nProgram Output:\n##############################\n\n" > ${LOG_DIR}/${prefix}${PAPI_LOG_NAME}'.log'
            ${PAPI_EXE} -u ${PAPI_CONFIG} 2>&1 >> ${LOG_DIR}/${prefix}${PAPI_LOG_NAME}'.log'
        ) &
    else
        # start papi without a configuration parallel to the executable
        (
            echo "$BASHPID" > .papi.pid
            sleep $PAPI_DELAY
            echo -en "### Starting PaPI .....\nSimulink Program: $SIMULINK_EXE\nDate: $DATE\nConfig: $PAPI_CONFIG\n\nProgram Output:\n##############################\n\n" > ${LOG_DIR}/${prefix}${PAPI_LOG_NAME}'.log'
            ${PAPI_EXE} -u .PaPI_StartConfigSimulinkController.xml 2>&1 >> ${LOG_DIR}/${prefix}${PAPI_LOG_NAME}'.log'
        ) &
    fi
fi


## start the Simulink executabel
##############################################################################################################
# function for control-c -> the simulink program is terminited before this runs
# -> just make sure the bash script is not terminted or the *.mat files will not be moved
function control_c(){
    # run if user hits control-c
    echo -en "\n### Aborting Simulink execution .....\n"
}
# trap keyboard interrupt (control-c)
trap control_c SIGINT

echo -en "\n### Starting Simulink executable '$SIMULINK_EXE' .....\n\n";
echo -en "### Starting Simulink executable .....\nProgram: $SIMULINK_EXE\nDate: $DATE\n\nProgram Output:\n##############################\n\n" > ${LOG_DIR}/${prefix}${SIMULINK_LOG_NAME}'.log'

sudo ${SIMULINK_EXE} 2>&1 | tee -a ${LOG_DIR}/${prefix}${SIMULINK_LOG_NAME}'.log'

echo -en "\n### Simulink executable was terminated.\n";


## move the *.mat files to the DATA_DIR
##############################################################################################################
# create move command
cat <<EOF > .move_mat
IN=\$1
OUT=\$2"\${IN##*/}"

echo -n "   "
mv -v \$IN \$OUT
EOF
chmod a+x .move_mat

# find and move all files
if [ ! -z "$MAT_FILE_PREFIX" ]; then

    # check that the directories exist
    if [ ! -d ${MAT_FILE_DIRECTORY} ]; then
        MAT_FILE_DIRECTORY='./'
    fi
    echo ""
    echo "### Moving *.mat files ....."

    find "$MAT_FILE_DIRECTORY" -maxdepth 1 -name "$MAT_FILE_PREFIX.mat" -exec ./.move_mat '{}' "$DATA_DIR/$prefix" \;
fi

echo ""
echo "..... done"

#chaning the user/group
REAL_USER=$(who am i | sed -e 's/ .*//')
REAL_GROUP=$(id -g -n "$REAL_USER")
chown -f -R "$REAL_USER":"$REAL_GROUP" "$DATA_DIR"
chown -f -R "$REAL_USER":"$REAL_GROUP" "$LOG_DIR"

# cleanup
rm -r .move_mat
rm -r .PaPI_StartConfigSimulinkController.xml

# wait on exit?
if [ "$WAIT_ON_EXIT" -eq 1 ]; then
    echo -en "\n\n\n"
    read -r -p "Press 'Enter' to exit and close this window: " line
fi

# only is papi is used
if [ -n "$PAPI_EXE" ]; then
    PAPI_SUBSHELL_PID=$(cat .papi.pid)
    rm -r .papi.pid

    # kill PaPI
    if [ "$KILL_PAPI_ON_EXIT" -eq 1 ]; then
        if [ ! -z "$PAPI_SUBSHELL_PID" ]; then
            PAPI_BASH_SCRIPT_PID=$(pgrep -P $PAPI_SUBSHELL_PID)
            if [ ! -z "$PAPI_BASH_SCRIPT_PID" ]; then
                PAPI_PID_1=$(pgrep -P $PAPI_BASH_SCRIPT_PID);
                if [ ! -z "$PAPI_PID_1" ]; then
                    PAPI_PID_2=$(pgrep -P $PAPI_PID_1);
                    if [ ! -z "$PAPI_PID_2" ]; then
                        PAPI_PID_3=$(pgrep -P $PAPI_PID_2)
                        # we got the process IDs -> kill PaPI
                        if [ ! -z "$PAPI_PID_3" ]; then
                            for PAPI_PID in $PAPI_PID_3; do
                                skill -kill -p "$PAPI_PID"
                            done
                        fi
                        for PAPI_PID in $PAPI_PID_2; do
                            skill -kill -p "$PAPI_PID"
                        done
                    fi
                    for PAPI_PID in $PAPI_PID_1; do
                        skill -kill -p "$PAPI_PID"
                    done
                fi
            fi
        fi
    fi
fi

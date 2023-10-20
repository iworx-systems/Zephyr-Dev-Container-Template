#!/bin/bash
#
# Name: WSL Embedded Environment Initialization Script
# Author: Scott Laboe
#
#-----------------------------------------------------
#
#                   Summary
#   This script is run on the host system (WSL) before
# running a development container. It is responsible for
# initializaing pipes (FIFOs) to the host OS which has 
# permissions needed to run programming and debug related
# commands that need to interface with hardware (i.e., 
# hardware debug probe).
#
#-----------------------------------------------------

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. scripts/pipe_vars.sh

#-----------------------------------------------------

# Translate input to the same case (lower)
PARAM_1="$1"
PARAM_2="$2"

#-----------------------------------------------------

# Parameter: name of pipe
Create_Pipe(){
    pipe_name=$1

    if [ ! -e $PIPE_DIR/"$pipe_name" ];
    then
        echo "Creating $pipe_name"
        mkdir -p $PIPE_DIR
        mkfifo $PIPE_DIR/"$pipe_name"
    fi
    echo
}

# Parameter: pipe name
Destroy_Pipe () { 
    pipe_name="$1"
    
    # Get process(es) ID
    pids=$(pgrep -f $PIPE_DIR/"$pipe_name")
    
    # Check if PID(s) exists
    if [ -z "$pids" ];   then
        echo "Nothing to destroy: Process $pipe_name isn't running"
    else
        ppids=$(ps -o ppid= -p "$pids")
        echo "$pipe_name"
        echo PPID: "${ppids[*]}"
        echo PID: "${pids[*]}"

        # Kill parent(s) before terminating listener process(es)
        kill "${ppids[@]}"
        kill "${pids[@]}"
        echo "Terminated"
    fi
    echo
}

# Parameter: pipe name
Create_Pipe_Listener(){
    pipe_name=$1

    #Get process ID
    pid=$(pgrep -f $PIPE_DIR/"$pipe_name")

    # Check if PID exists
    if [ -z "$pid" ];   then
        echo "Creating $pipe_name listener..."
        mkdir -p $PIPE_DIR/tmp
        nohup bash -c scripts/"$pipe_name"Listener.sh> $PIPE_DIR/tmp/"$pipe_name".out 2>&1 & 
        echo "$pipe_name Listener PID: $!"
    else
        echo "$pipe_name Listener is already running."
    fi
    echo
}

#------------------------CMDs--------------------------

# Destroy pipe listener(s)
if [ "$PARAM_1" = "-destroy" ]; then
    if [ -n "$PARAM_2" ];  then
        Destroy_Pipe "$PARAM_2"
    else
        # Destroy all pipes
        for pipe_name in "${PIPES[@]}";   do
            Destroy_Pipe "$pipe_name"
        done
    fi
    exit
fi

# Initialize pipes
for pipe_name in "${PIPES[@]}";   do
    Create_Pipe "$pipe_name"
    Create_Pipe_Listener "$pipe_name"
done

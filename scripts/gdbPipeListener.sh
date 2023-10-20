#!/bin/bash

. scripts/pipe_vars.sh

# Run command through named pipe (WSL redirects to windows execution env for executables)
while [ true ] 
do
    cmd="$(cat $PIPE_DIR/"${PIPES[$GDB]}")"

    # replace single quotes with double
    cmd=$(echo "$cmd" | sed 's/'\''/"/g')

    # Start gdb server
    powershell.exe "$WIN_NU_OPENOCD_PATH" $cmd

    echo "GDB Operation Complete"
done
#!/bin/bash

# To overcome the inability of the Windows CMD prompt to handle UNC paths
# I am copying the binary file to the public documents directory everytime
# a write command is run. I have set the location of the file as an environment
# variable in the "".devcontainer/Dockerfile". If you change the location here
# you MUST change it in the Dockerfile so tasks.json are referencing the correct
# location.

. scripts/pipe_vars.sh

# Create empty file if nothing exists
touch "/mnt/c/Users/Public/Documents/zephyr.bin"

# Change path to windows drive so cmd.exe doesn't complain
# about UNC paths not being supported.
cd /mnt/c

# Run command through named pipe (WSL redirects to windows execution env for executables)
while [ true ]
do
    # Have to use absolute path since we are in /mnt/c now
    cmd="$(cat $SCRIPT_DIR/../$PIPE_DIR/"${PIPES[$NULINK]}")"
    if [ -z "$cmd" ]; then
        # Display help message
        "$LINUX_NULINK_PATH/$NULINK_EXE"
    else
        echo "$NULINK_EXE $cmd"
        
        # Copy binary and run command
        cp "$SCRIPT_DIR/../build/app/zephyr/zephyr.bin" "/mnt/c/Users/Public/Documents/zephyr.bin" \
        && cmd.exe /s /c "cd $WIN_NULINK_PATH & $NULINK_EXE $cmd"
    fi
    echo "Nulink Operation Complete"
done

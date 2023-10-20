#!/bin/bash

. scripts/pipe_vars.sh

# Clear previous output
> $PIPE_DIR/tmp/"${PIPES[$NULINK]}".out

output_message=""

if [ $# -eq 0 ];
then
    #display available commands
    > $PIPE_DIR/"${PIPES[$NULINK]}"
    output_message="!!! Enter one of the commands above as a parameter i.e, \"scripts/runNulinkCMD.sh -S\" !!!"
else
    # Write nulink command
    echo "$@" > $PIPE_DIR/"${PIPES[$NULINK]}"
fi

# Monitor output and quit once "Nulink Operation Complete" is output
bash -c '. scripts/pipe_vars.sh && tail -n +0 -f $PIPE_DIR/tmp/"${PIPES[$NULINK]}".out | { sed "/Nulink Operation Complete/ q" && kill $$ ;}'

echo "$output_message"
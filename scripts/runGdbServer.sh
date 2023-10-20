#!/bin/bash

. scripts/pipe_vars.sh

# Clear previous output
> "$PIPE_DIR/tmp/${PIPES[$GDB]}".out

output_message=""

if [ $# -eq 0 ];
then
    output_message="!!! Must supply parameters i.e, \"scripts/runGdbServer.sh -f interface/nulink.cfg\" !!!"
else
    # Write gdb command
    echo "$@" > $PIPE_DIR/"${PIPES[$GDB]}"

    # Monitor output and quit once "GDB Operation Complete" is output
    bash -c '. scripts/pipe_vars.sh && tail -n +0 -f "$PIPE_DIR/tmp/${PIPES[$GDB]}".out | { sed "/GDB Operation Complete/ q" && kill $$ ;}'
fi

echo "$output_message"
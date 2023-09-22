#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

text=$(cat $1)

# Router
code=$(for i in $(bash -c "ls $SCRIPT_DIR/bin/sources/*.ml"); do
    name=$(basename "$i" | sed 's/...$//')
    if [ "$name" != "parse" ]; then
        printf "; Dream.get \"\\\\/$name\\\\/**\" (fun req -> Lwt.bind (Sources.${name^}.parse req) Dream.html)"
    fi
done)

text=$(echo "$text" | sed "s/(\* Service parser replaced here (\/preprocceser.sh) \*)/$code/g")

# Submit
code=$(for i in $(bash -c "ls $SCRIPT_DIR/bin/sources/*.ml"); do
    name=$(basename "$i" | sed 's/...$//')
    if [ "$name" != "parse" ]; then
        printf "else if List.mem domain Sources.${name^}.domain then some \"$name\" "
    fi
done)

text=$(echo "$text" | sed "s/(\* Submit replaced here (\/preprocceser.sh) \*)/$code/g")

# Finish
echo "$text"

#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

text=$(cat "$1")

# Router
code=$(for i in $(bash -c "ls $SCRIPT_DIR/bin/sources/*.ml"); do
    name=$(basename "$i" | sed 's/...$//')
    if [ "$name" != "parse" ]; then
        up_name="$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"
        printf "; Dream.get \"\\\\/%s\\\\/**\" (fun req -> Lwt.bind (Sources.%s.parse req) Dream.html)" "$name" "$up_name"
    fi
done)

text=$(echo "$text" | sed "s/(\* Service parser replaced here (\/preprocceser.sh) \*)/$code/g")

# Submit
code=$(for i in $(bash -c "ls $SCRIPT_DIR/bin/sources/*.ml"); do
    name=$(basename "$i" | sed 's/...$//')
    if [ "$name" != "parse" ]; then
        up_name="$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"
        printf "else if List.mem domain Sources.%s.domain then some \"%s\" " "$up_name" "$name"
    fi
done)

text=$(echo "$text" | sed "s/(\* Submit replaced here (\/preprocceser.sh) \*)/$code/g")

# Parse
code=$(for i in $(bash -c "ls $SCRIPT_DIR/bin/sources/*.ml"); do
    name=$(basename "$i" | sed 's/...$//')
    if [ "$name" != "parse" ]; then
        domains=$(cat "$i" | grep -o "let *domain *= *\[[^\]*\]" | grep -o "\[[^\]*\]")
        printf "else if List.mem domain %s then Option.some \"%s\" " "$domains" "$name"
    fi
done)

text=$(echo "$text" | sed "s/(\* Names replaced here (\/preprocceser.sh) \*)/$code/g")

# Finish
echo "$text"

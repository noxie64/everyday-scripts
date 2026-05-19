#!/bin/bash

HELP=" \
md2pretty <file> {args to pass down to pandoc}
"

if [ ${#@} -eq 0 ] || [ ${#@} -gt 1 ]; then
    echo "$HELP"
    exit 1
fi

pandoc "$1" -o "$(echo "$1" | grep -oE ".*\.")"pdf --from markdown --template eisvogel --listings "${@:2}"

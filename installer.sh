#!/bin/bash
GREEN='\e[1;32m'
RED='\e[1;31m'
RESET='\e[0m'

## INFO ##
# `sh`: all scripts set under this key must be in the ./scripts/sh-dir

ok()
{
    printf "${GREEN}$1${RESET}\n" ${@:2}
}

bad()
{
    printf "${RED}$1${RESET}\n" ${@:2}
}

for obj in $(jq -cr '.["sh"] | to_entries | .[]' install.config.json); do
    src="./scripts/sh/$(echo "$obj" | jq -r '.key')"
    target="$(echo "$obj" | jq -r '.value')"
    chmod +x "$src"
    chmod_status=$?

    ln -sf "$(realpath "$src")" "$target"
    if [ $? -eq 0 ] && [ $chmod_status -eq 0 ]; then
        ok "Linked %s -> %s" "$src" "$target"
    else
        bad "Failed to link %s -> %s" "$src" "$target"
    fi
done

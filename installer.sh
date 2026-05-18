#!/bin/sh

for obj in $(jq -cr 'to_entries | .[]' install.config.json); do
    src="$(echo "$obj" | jq -r '.key')"
    target="$(echo "$obj" | jq -r '.value')"
    chmod +x "$src"

    ln -sf "$(realpath "$src")" "$target"
    if [ $? -eq 0 ]; then
        printf '\e[1;32mLinked %s -> %s\e[0m\n' "$src" "$target"
    else
        printf '\e[1;31mFailed to link %s -> %s\e[0m\n' "$src" "$target"
    fi
done

#!/bin/bash
nmcli networking off
sleep 2s
nmcli networking on

check_status ()
{
    nmcli -f CONNECTIVITY general | tail -n 1 | tr -d ' '
}

while [[ "$(check_status)" != "portal" ]]; do
    sleep 1s
done

xdg-open http://neverssl.com

#!/usr/bin/env python3

from argparse import ArgumentParser
from sys import argv
from os.path import isfile
from json import loads
import subprocess
import gnupg
from getpass import getpass

def main():
    parser = ArgumentParser(
            prog="proton2pass",
            description="Add proton-json-entries to pass."
    )

    parser.add_argument('json')
    parser.add_argument('-v', '--vault')
    parser.add_argument('-e', '--encrypted', action="store_true", help="Wether or not the file is encrypted with pgp.")
    args = parser.parse_args()

    if not isfile(args.json):
        print("Input file not found!")
        exit(1)
    json = get_json(args.encrypted, args.json)
    parse_vault(json["vaults"][args.vault] if args.vault else next(iter(dict(json["vaults"]).values())))

def get_json(encrypted: bool, file: str):
    text = ""

    if encrypted:
        gpg = gnupg.GPG()
        with open(file, 'rb') as f:
            text = str(gpg.decrypt_file(f, passphrase=getpass("Enter passphrase: ")))
    else:
        with open(file, 'r') as f:
            text = '\n'.join(f.readlines())

    return loads(text)

def parse_vault(vault: dict):
    print(f"Entering vauld {vault['name']}")
    for item in vault["items"]:
        if item['data']["type"] != "login":
            continue
        item_name = item["data"]["metadata"]["name"]
        content = item["data"]["content"]


        username = content["itemUsername"]
        email = content["itemEmail"]
        password = content["password"]
        urls = content["urls"]

        entry = f"{password}\n"
        if username != "" and email != "":
            entry += f"login: {username}\n"
            entry += f"email: {email}\n"
        else:
            entry += f"login: {username if username != '' else email}\n"

        for url in urls:
            entry += f"url: {url}\n"
        print(f"Inserting {item_name}...")
        persist_to_pass(item_name, entry)

def persist_to_pass(name: str, entry: str):
    subprocess.run(
            ["pass", "insert", "--multiline", name],
            input=entry.encode(),
            check=True
            )
if __name__ == '__main__':
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from typing import Optional
import argparse
import os
import sys

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Generate and run/print the small subset of openssl commands I care about
Thank you @shadyabhi for the openssl help!

Examples:
    {sys.argv[0]} ./cert.txt dates
    {sys.argv[0]} --servername example.com 127.0.0.1 md5
Help:
    Please see Benjamin Kane for help.
Code at https://github.com/bbkane/dotfiles
"""


def get(cert_or_host: str, servername: Optional[str]) -> str:
    "generate the part of the openssl command to get the cert"
    if os.path.exists(cert_or_host):
        return f"cat {cert_or_host}"
    if servername == "NONE":  # don't use SNI
        # https://stackoverflow.com/a/50770880/2958070
        # NOTE: might break if openssl updates, see ^
        return f"echo | openssl s_client -connect {cert_or_host}:443 2> /dev/null"
    if servername is None:
        servername = cert_or_host
    return f"echo | openssl s_client -connect {cert_or_host}:443 -servername {servername} 2> /dev/null"


query = {
    "all": "",  # do nothing
    "dates": " | openssl x509 -in /dev/stdin -noout -dates",
    "md5": " | openssl x509 -in /dev/stdin -noout -fingerprint -md5",
    "pem": " | openssl x509 -in /dev/stdin -outform pem",
    "subject": " | openssl x509 -in /dev/stdin -noout -subject",
    "san": ' | openssl x509 -in /dev/stdin -text -noout | awk -F, -v OFS="\\n" \'/Subject: /{x=gsub(/.*CN=/, "  "); printf "Common Name:\\n"$x} /DNS:/{gsub(/ *DNS:/, "  "); $1=$1; printf "\\n\\nSAN Domains:\\n" $0"\\n"}\'',
    "text": " | openssl x509 -in /dev/stdin -noout -text",
}


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument(
        "cert_or_host",
        help="filepath or host (www.example.com) to connect to. Appends :443 automatically. Also used for SNI (also see --servername)",
    )
    parser.add_argument(
        "query",
        choices=query.keys(),
        help="filter to apply to cert. 'all' doesn't do any filtering",
    )
    parser.add_argument(
        "--servername",
        "-s",
        help="servername to use. Defaults to cert_or_host. Pass NONE to not use SNI",
    )
    parser.add_argument(
        "--silent",
        action="store_true",
        help="Don't print generated openssl command in addition to running it",
    )
    return parser.parse_args(*args, **kwargs)


def main():
    args = parse_args()
    cmd = get(args.cert_or_host, args.servername) + query[args.query]
    if not args.silent:
        print("$", cmd, end="\n\n")
    os.system(cmd)

    # do real work


if __name__ == "__main__":
    main()

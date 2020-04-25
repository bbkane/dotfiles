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
    {sys.argv[0]} example.com -u 127.0.0.1 md5
Help:
    Please see Benjamin Kane for help.
Code at https://github.com/bbkane/dotfiles
"""


def get(cert_or_host: str, underlying_host: Optional[str]) -> str:
    "generate the part of the openssl command to get the cert"
    if os.path.exists(cert_or_host):
        return f"cat {cert_or_host}"
    if underlying_host:
        return f"echo | openssl s_client -connect {underlying_host}:443 -servername {cert_or_host} 2> /dev/null"
    # just the host
    return f"echo | openssl s_client -connect {cert_or_host}:443 2> /dev/null"


query = {
    "all": "",  # do nothing
    "dates": " | openssl x509 -noout -dates",
    "md5": " | openssl x509 -noout -fingerprint -md5",
    "pem": " | openssl x509 -outform pem",
    "subject": " | openssl x509 -noout -subject",
    "san": ' | openssl x509 -text -noout | awk -F, -v OFS="\\n" \'/Subject: /{x=gsub(/.*CN=/, "  "); printf "Common Name:\\n"$x} /DNS:/{gsub(/ *DNS:/, "  "); $1=$1; printf "\\n\\nSAN Domains:\\n" $0"\\n"}\'',
    "text": " | openssl x509 -noout -text",
}


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument("cert_or_host", help="filepath or host (www.example.com)")
    parser.add_argument(
        "query",
        choices=query.keys(),
        help="filter to apply to cert. 'all' doesn't do any filtering",
    )
    parser.add_argument(
        "--underlying_host",
        "-u",
        help="host to connect to. Useful when testing certs on multiple hosts. Appends :443 automatically",
    )
    parser.add_argument(
        "--print",
        "-p",
        action="store_true",
        help="print generated openssl command instead of running it",
    )
    return parser.parse_args(*args, **kwargs)


def main():
    args = parse_args()
    cmd = get(args.cert_or_host, args.underlying_host) + query[args.query]
    if args.print:
        print(cmd)
    else:
        os.system(cmd)

    # do real work


if __name__ == "__main__":
    main()

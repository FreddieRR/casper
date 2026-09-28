"""Command-line entry point for Casper.

Only `--version` exists for now, so CI has something real to run. Commands such as
`casper ingest` (week 2), `casper ask` (week 3) and `casper keys create` (week 5) are
yours to design and add.
"""

import argparse

from casper import __version__


def main() -> None:
    parser = argparse.ArgumentParser(prog="casper", description=__doc__.splitlines()[0])
    parser.add_argument("--version", action="version", version=f"casper {__version__}")
    parser.parse_args()
    parser.print_help()


if __name__ == "__main__":
    main()

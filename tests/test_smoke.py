"""Smoke tests: prove the package installs, imports and reports its version."""

import subprocess
import sys

import casper


def test_package_has_version():
    assert isinstance(casper.__version__, str)
    assert casper.__version__


def test_cli_prints_version():
    result = subprocess.run(
        [sys.executable, "-m", "casper.cli", "--version"],
        capture_output=True,
        text=True,
        check=True,
    )
    assert result.stdout.strip() == f"casper {casper.__version__}"

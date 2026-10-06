#!/usr/bin/env bash
# Print the versions of the tools Casper needs. Read-only: installs and changes nothing.
# Usage: make check-env   (or: bash scripts/check_env.sh)

set -u

show() {
  local label="$1"
  shift
  printf '%-10s ' "$label"
  if command -v "$1" >/dev/null 2>&1; then
    "$@" 2>&1 | head -n 1
  else
    echo "not installed"
  fi
}

printf '%-10s %s\n' "os" "$(uname -srm)"
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  printf '%-10s %s\n' "distro" "$(. /etc/os-release && echo "$PRETTY_NAME")"
fi
if grep -qi microsoft /proc/version 2>/dev/null; then
  printf '%-10s %s\n' "wsl" "yes (running inside WSL)"
fi

show "git" git --version
show "uv" uv --version
show "python" python3 --version
show "docker" docker --version
show "compose" docker compose version
show "ollama" ollama --version
show "tailscale" tailscale version

printf '%-10s ' "gpu"
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader
else
  echo "nvidia-smi not found (expected on a Mac; run this on the G14)"
fi

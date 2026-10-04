#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for LSC Enterprise Data Harmonization.
# Prepares system deps + a Python venv with the data/semantic/dev stack.
set -euo pipefail

cd "$(dirname "$0")/.."

# System packages: venv support + build toolchain for any source wheels.
# Ubuntu 24.04 ships Python 3.12 but not ensurepip/venv by default (PEP 668).
if ! dpkg -s python3.12-venv >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    python3.12-venv python3-dev build-essential
fi

# Python virtual environment (required: base image is externally-managed).
if [ ! -x .venv/bin/python ]; then
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
. .venv/bin/activate

python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

echo "Environment ready. Activate with: source .venv/bin/activate"

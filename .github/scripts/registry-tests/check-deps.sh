#!/usr/bin/env bash
set -euo pipefail

# Without this check, a requirement bump is green without ever being installed.
pip install -r tools/registry/requirements.txt -r set-up-repositories/requirements.txt
python3 -m py_compile tools/registry/backfill.py set-up-repositories/*.py
python3 -c 'import boto3; import dotenv; import requests'

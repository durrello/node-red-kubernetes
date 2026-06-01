#!/usr/bin/env bash
# Generate a bcrypt hash for the Node-RED admin password.
# Usage: ./hash-password.sh 'your-strong-password'
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 '<password>'" >&2
  exit 1
fi

# Use the official Node-RED admin hash utility via the container image.
docker run --rm -it nodered/node-red:4.0 \
  npx node-red-admin hash-pw <<EOF
$1
EOF

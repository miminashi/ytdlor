#!/bin/sh

#
# Data migration script
#   from sqlite3 to postgresql
#

set -e

POSTGRES_URL="postgres://postgres:password@db/template1"

# Try to connect to postgresql
seq 1 10 |
  while read -r i; do
    echo "Trying to connect to postgresql try:${i}" >&2
    if sequel -E "${POSTGRES_URL}" -c 'p DB' > /dev/null; then
      break
    fi
    if [ "${i}" = "10" ]; then
      echo "Could not connect to postgresql" >&2
      exit 1
    fi
    sleep 1
  done

# Create database on postgresql
#   - it fails if database already exists
sequel -E "${POSTGRES_URL}" <<'EOF'
DB.run('CREATE DATABASE "ytdlor_production" ENCODING = \'unicode\'')
EOF

# Copy data from sqlite3 to postgresql
sequel -E -C sqlite:///var/opt/ytdlor/db/production.sqlite3 postgres://postgres:password@db/ytdlor_production

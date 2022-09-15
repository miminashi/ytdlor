#!/bin/sh

set -eu

echo "autoremoved started" >&2
echo "interval is ${YTDLOR_AUTOREMOVE_INTERVAL} mins" >&2

while :; do
  sleep $((60 * YTDLOR_AUTOREMOVE_INTERVAL))
  ./autoremove.sh
done

#!/bin/sh

set -eu

echo "autoremoved started" >&2
echo "remove interval is ${YTDLOR_AUTOREMOVE_INTERVAL} mins" >&2
echo "remove failed interval is ${YTDLOR_AUTOREMOVE_FAILED_INTERVAL} mins" >&2

while :; do
  sleep $((60 * YTDLOR_AUTOREMOVE_INTERVAL))
  rails demosite:autoremove
done

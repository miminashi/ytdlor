#!/bin/sh

set -e

pidfile="/opt/app/tmp/pids/server.pid"

if [ -f $pidfile ]; then
  rm $pidfile
fi

exec rails server -b 0.0.0.0

#!/usr/bin/env bash

set -euo pipefail

PIDFILE=/tmp/wf-recorder.pid

if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    echo "{\"text\":\"🔴REC\", \"tooltip\":\"录制中\"}"
else
    echo ""
fi

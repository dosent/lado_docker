#!/bin/sh
set -eu

# Codex listens on container loopback; Docker forwards published ports to the
# container interface, so bridge the published port back to that loopback.
socat TCP-LISTEN:1455,bind=0.0.0.0,reuseaddr,fork TCP:127.0.0.1:1455 &
proxy_pid=$!

lado server --host 0.0.0.0 --port 8000 &
server_pid=$!

forward_stop() {
    kill -TERM "$server_pid" 2>/dev/null || true
    kill -TERM "$proxy_pid" 2>/dev/null || true
}
trap forward_stop TERM INT

while ! python -c 'from urllib.request import urlopen; urlopen("http://127.0.0.1:8000/api/health", timeout=1)' >/dev/null 2>&1; do
    if ! kill -0 "$server_pid" 2>/dev/null; then
        wait "$server_pid"
        exit $?
    fi
    sleep 0.25
done

printf '\nLADO UI: %s/?token=' "${LADO_PUBLIC_URL:-http://localhost:9898}"
cat "$LADO_HOME/server-token"
printf '\n'

wait "$server_pid"

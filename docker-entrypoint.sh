#!/bin/sh
# Update CA certificates if any custom certs are mounted
if [ -d /usr/local/share/ca-certificates ] && [ "$(ls -A /usr/local/share/ca-certificates 2>/dev/null)" ]; then
    update-ca-certificates 2>/dev/null
fi

exec "$@"

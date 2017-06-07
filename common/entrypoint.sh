#!/bin/bash

USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m user
export HOME=/home/user

# This is used to execute any helper scripts we might have that need to get run
# before the actual app starts.
if [ -d /opt/simple-auth/entrypoint.d ]; then
    for f in /opt/simple-auth/entrypoint.d/*.sh; do
        [ -f "$f" ] && . "$f"
    done
fi

exec /usr/local/bin/gosu user "$@"


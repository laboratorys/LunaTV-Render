#!/bin/sh
nohup /app/backup2gh &
sleep 5

retry_count=0
max_retries=30

while [ $retry_count -lt $max_retries ]; do
    if [ -f "/tmp/restore.lock" ]; then
        echo "$(date "+%Y-%m-%d %H:%M:%S") Waiting for restore from github..."
        sleep 5
        retry_count=$((retry_count + 1))
    else
        break
    fi
done

echo "$(date "+%Y-%m-%d %H:%M:%S") Starting app server..."
exec node start.js
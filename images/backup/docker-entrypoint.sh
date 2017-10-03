#!/bin/sh
set -e

echo "[I] Creating cron job."
echo "$CRON_EXP /usr/local/bin/app-backup" > /var/spool/cron/crontabs/root

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
fi

echo "[I] Entrypoint tasks complete. Starting crond."
exec "$@"

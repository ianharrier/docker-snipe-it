#!/bin/sh
set -e

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
fi

echo "[I] Creating cron jobs."
echo "* * * * * /usr/local/bin/laravel-schedule" > /var/spool/cron/crontabs/root
if [ "$LDAP_SYNC_OPERATION" != "disable" ]; then
    echo "$LDAP_SYNC_CRON_EXP /usr/local/bin/snipeit-ldap-sync" >> /var/spool/cron/crontabs/root
fi

echo "[I] Entrypoint tasks complete. Starting crond."
exec "$@"

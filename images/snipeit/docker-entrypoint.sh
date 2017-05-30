#!/bin/sh
set -e

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    echo "date.timezone = $TIMEZONE" > /etc/php7/conf.d/timezone.ini
fi

if [ ! "$(cat storage/private_secrets/app_key 2>/dev/null || echo)" ]; then
    echo "[I] Setting the application key."
    echo "$(php artisan key:generate --show)" > storage/private_secrets/app_key
fi

echo "[I] Loading the application key."
APP_KEY=$(cat storage/private_secrets/app_key)

echo "[I] Entrypoint tasks complete. Starting Snipe-IT."
exec "$@"



#rm -r "/var/www/html/storage/private_uploads" && ln -fs "/var/lib/snipeit/data/private_uploads" "/var/www/html/storage/private_uploads" \
#      && rm -rf "/var/www/html/public/uploads" && ln -fs "/var/lib/snipeit/data/uploads" "/var/www/html/public/uploads" \
#      && rm -r "/var/www/html/storage/app/backups" && ln -fs "/var/lib/snipeit/dumps" "/var/www/html/storage/app/backups"

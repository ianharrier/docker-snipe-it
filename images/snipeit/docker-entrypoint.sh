#!/bin/sh
set -e

echo "[I] Creating directory structure."
mkdir -p /var/lib/snipeit/private_uploads
mkdir -p /var/lib/snipeit/uploads/assets
mkdir -p /var/lib/snipeit/uploads/avatars
mkdir -p /var/lib/snipeit/uploads/barcodes
mkdir -p /var/lib/snipeit/uploads/models
mkdir -p /var/lib/snipeit/uploads/suppliers

echo "[I] Setting file permissions."
chgrp -R apache /var/lib/snipeit/private_uploads /var/lib/snipeit/uploads
chmod -R ug+rwx /var/lib/snipeit/private_uploads /var/lib/snipeit/uploads

if [ ! "$(cat /var/lib/snipeit/app_key 2>/dev/null || echo)" ]; then
    echo "[I] Setting the application key."
    echo "$(php artisan key:generate --show)" > /var/lib/snipeit/app_key
fi

echo "[I] Loading the application key."
sed -i "s|^APP_KEY=.*|APP_KEY=$(cat /var/lib/snipeit/app_key)|g" .env

echo "[I] Updating the config cache."
php artisan config:cache

echo "[I] Waiting for MySQL container to complete initialization tasks."
DB_READY=false
while [ "$DB_READY" = "false" ]; do
    sleep 1
    nc -z db 3306 &>/dev/null && DB_READY=true || DB_READY=false
done

echo "[I] Migrating the database."
php artisan migrate --force

echo "[I] Entrypoint tasks complete. Starting Snipe-IT."
exec "$@"

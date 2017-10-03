#!/bin/sh
set -e

START_TIME=$(date +%s)

cd "$HOST_PATH"

echo "[I] Performing LDAP sync."
docker exec -i "$(docker-compose ps -q web)" sh -c 'php artisan snipeit:ldap-sync'

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."

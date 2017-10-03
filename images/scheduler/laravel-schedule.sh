#!/bin/sh
set -e

START_TIME=$(date +%s)

cd "$HOST_PATH"

echo "[I] Triggering Laravel scheduling system."
docker exec -i "$(docker-compose ps -q web)" sh -c 'php artisan schedule:run'

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."

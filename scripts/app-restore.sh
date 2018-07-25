#!/bin/sh
set -e

START_TIME=$(date +%s)

if [ ! -d .git ]; then
    echo "[E] This script needs to run from the top directory of the repo. Current working directory:"
    echo "      $(pwd)"
    exit 1
fi

if [ ! $1 ]; then
    echo "[E] Specify the name of a backup file to restore. Example:"
    echo "      $0 20170501T031500+0000.tar.gz"
    exit 1
fi

if [ ! -e "backups/$1" ]; then
    echo "[E] The file '$1' does not exist."
    exit 1
fi

if [ -d backups/tmp_restore ]; then
    echo "[W] Cleaning up from a previously-failed restore."
    rm -rf backups/tmp_restore
fi

BACKUP_FILE="$1"

echo "[I] Creating working directory."
mkdir -p backups/tmp_restore

echo "[I] Shutting down and removing application stack."
docker-compose down &>/dev/null

echo "[I] Removing Snipe-IT and MySQL persistent data."
rm -rf volumes/web/data volumes/db/data

echo "[I] Extracting backup."
tar -xf "backups/$BACKUP_FILE" -C backups/tmp_restore

echo "[I] Creating and starting MySQL container."
docker-compose up -d db &>/dev/null

echo "[I] Waiting for MySQL container to complete initialization tasks."
until (docker-compose logs db | grep "MySQL init process done") &>/dev/null; do
    sleep 5
done

echo "[I] Restoring MySQL database."
docker exec -i "$(docker-compose ps -q db)" sh -c 'exec mysql --database "$MYSQL_DATABASE" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" 2>/dev/null' < backups/tmp_restore/db.sql

echo "[I] Restoring Snipe-IT data."
if [ ! -d volumes/web ]; then
    mkdir -p volumes/web
fi
mv backups/tmp_restore/data volumes/web/data/

echo "[I] Creating and starting application stack."
docker-compose up -d &>/dev/null

echo "[I] Removing working directory."
rm -rf backups/tmp_restore

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."

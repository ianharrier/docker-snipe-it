#!/bin/sh
set -e

START_TIME=$(date +%s)

cd "$HOST_PATH"

if [ ! $1 ]; then
    echo "[E] Specify the name of a backup file to restore. Example:"
    echo "      docker-compose exec backup app-restore 20170501T031500+0000.tar.gz"
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

echo "[I] Shutting down and removing scheduler container."
docker-compose stop scheduler &>/dev/null
docker-compose rm --force scheduler &>/dev/null

echo "[I] Shutting down and removing Snipe-IT container."
docker-compose stop web &>/dev/null
docker-compose rm --force web &>/dev/null

echo "[I] Shutting down and removing MySQL container."
docker-compose stop db &>/dev/null
docker-compose rm --force db &>/dev/null

echo "[I] Removing Snipe-IT and MySQL persistent data."
rm -rf volumes/web/data volumes/db/data

echo "[I] Extracting backup."
tar -xf "backups/$BACKUP_FILE" -C backups/tmp_restore

echo "[I] Creating and starting MySQL container."
docker-compose up -d db &>/dev/null

echo "[I] Waiting for MySQL container to complete initialization tasks."
DB_READY=false
while [ "$DB_READY" = "false" ]; do
    nc -z db 3306 &>/dev/null && DB_READY=true || DB_READY=false
	sleep 5
done

echo "[I] Restoring MySQL database."
docker exec -i "$(docker-compose ps -q db)" sh -c 'exec mysql --database "$MYSQL_DATABASE" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" 2>/dev/null' < backups/tmp_restore/db.sql

echo "[I] Restoring Snipe-IT data."
if [ ! -d volumes/web ]; then
    mkdir -p volumes/web
fi
mv backups/tmp_restore/data volumes/web/data/

echo "[I] Creating and starting Snipe-IT container."
docker-compose up -d web &>/dev/null

echo "[I] Creating and starting scheduler container."
docker-compose up -d scheduler &>/dev/null

echo "[I] Removing working directory."
rm -rf backups/tmp_restore

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."

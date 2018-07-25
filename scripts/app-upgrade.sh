#!/bin/sh
set -e

START_TIME=$(date +%s)

if [ ! -d .git ]; then
    echo "[E] This script needs to run from the top directory of the repo. Current working directory:"
    echo "      $(pwd)"
    exit 1
fi

echo "=== Shutting down scheduler container. ========================================="
docker-compose stop scheduler

echo "=== Shutting down web container. ==============================================="
docker-compose stop web

# The backup process will fail if the db container is not started.

echo "=== Starting cron container. ==================================================="
docker-compose up -d cron

echo "=== Backing up application stack. =============================================="
docker-compose exec cron app-backup

echo "=== Removing currnet application stack. ========================================"
docker-compose down

echo "=== Pulling changes from repo. ================================================="
git pull

echo "=== Updating environment file. ================================================="
OLD_SNIPEIT_VERSION=$(grep ^SNIPEIT_VERSION= .env | cut -d = -f 2)
NEW_SNIPEIT_VERSION=$(grep ^SNIPEIT_VERSION= .env.template | cut -d = -f 2)
echo "[I] Upgrading Snipe-IT from '$OLD_SNIPEIT_VERSION' to '$NEW_SNIPEIT_VERSION'."
sed -i.bak -e "s/^SNIPEIT_VERSION=.*/SNIPEIT_VERSION=$NEW_SNIPEIT_VERSION/g" .env

echo "=== Deleting old images. ======================================================="
IMAGE_CRON=$(docker images ianharrier/snipeit-cron -q)
IMAGE_SCHEDULER=$(docker images ianharrier/snipeit-scheduler -q)
IMAGE_WEB=$(docker images ianharrier/snipeit -q)
docker rmi $IMAGE_CRON $IMAGE_SCHEDULER $IMAGE_WEB

echo "=== Building new images. ======================================================="
docker-compose build --pull --no-cache

echo "=== Pulling updated database image. ============================================"
docker-compose pull db

echo "=== Restoring application stack to most recent backup. ========================="
cd backups
LATEST_BACKUP=$(ls -1tr *.tar.gz 2> /dev/null | tail -n 1)
cd ..
./scripts/app-restore.sh $LATEST_BACKUP

END_TIME=$(date +%s)

echo "=== Upgrade complete. =========================================================="
echo "[I] Time elapsed: $((END_TIME-START_TIME)) seconds."

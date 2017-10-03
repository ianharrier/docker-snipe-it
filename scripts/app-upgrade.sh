#!/bin/sh
set -e

START_TIME=$(date +%s)

echo "=== Shutting down scheduler container. ========================================="
docker-compose stop scheduler

echo "=== Shutting down web container. ==============================================="
docker-compose stop web

# The backup process will fail if the db container is not started.

echo "=== Starting backup container. ================================================="
docker-compose up -d backup

echo "=== Backing up application stack. =============================================="
docker-compose exec backup app-backup

echo "=== Removing currnet application stack. ========================================"
docker-compose down

echo "=== Pulling changes from repo. ================================================="
git pull

echo "=== Updating environment file. ================================================="
OLD_SNIPEIT_VERSION=$(grep ^SNIPEIT_VERSION= .env | cut -d = -f 2)
NEW_SNIPEIT_VERSION=$(grep ^SNIPEIT_VERSION= .env.template | cut -d = -f 2)
echo "[I] Upgrading Snipe-IT from '$OLD_SNIPEIT_VERSION' to '$NEW_SNIPEIT_VERSION'."
sed -i.bak "s/^SNIPEIT_VERSION=.*/SNIPEIT_VERSION=$NEW_SNIPEIT_VERSION/g" .env

echo "=== Building new images. ======================================================="
docker-compose build --pull

echo "=== Pulling updated database image. ============================================"
docker-compose pull db

echo "=== Starting backup container. ================================================="
docker-compose up -d backup

echo "=== Restoring application stack to most recent backup. ========================="
cd backups
LATEST_BACKUP=$(ls -1tr *.tar.gz 2> /dev/null | tail -n 1)
cd ..
docker-compose exec backup app-restore $LATEST_BACKUP

END_TIME=$(date +%s)

echo "=== Upgrade complete. =========================================================="
echo "[I] Time elapsed: $((END_TIME-START_TIME)) seconds."

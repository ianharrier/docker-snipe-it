# docker-snipe-it

Dockerized Snipe-IT

### Contents

* [About](#about)
* [How-to guides](#how-to-guides)
    * [Installing](#installing)
    * [Upgrading](#upgrading)
    * [Running a one-time manual backup](#running-a-one-time-manual-backup)
    * [Restoring from a backup](#restoring-from-a-backup)
    * [Uninstalling](#uninstalling)

## About

This repo uses [Docker](https://www.docker.com) and [Docker Compose](https://docs.docker.com/compose/) to automate the deployment of [Snipe-IT](https://github.com/snipe/snipe-it).

This is more than just a Snipe-IT image. Included in this repo is everything you need to get Snipe-IT up and running as quickly as possible and a **pre-configured backup and restoration solution**.

## How-to guides

*Note: some of the commands in these guides may require root access to your system. If that is the case, either run the commands while logged in to the root account, or simulate a login to the root account using `sudo -i`. Due to the way environment variables are passed on some systems, typing `sudo` before each command is __not__ a supported method of running the commands in these guides with root access.*

### Installing

1. Ensure the following are installed on your system:

    * [Docker](https://docs.docker.com/engine/installation/)
    * [Docker Compose](https://docs.docker.com/compose/install/) **Warning: [installing as a container](https://docs.docker.com/compose/install/#install-as-a-container) is not supported.**
    * `git`
    * `tar`

2. Clone this repo to a location on your system. *Note: in all of the guides on this page, it is assumed the repo is cloned to `/srv/docker/snipeit`.*

    ```shell
    git clone https://github.com/ianharrier/docker-snipe-it.git /srv/docker/snipeit
    ```

3. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/snipeit
    ```

4. Create the `.env` file using `.env.template` as a template.

    ```shell
    cp .env.template .env
    ```

5. Using a text editor, read the comments in the `.env` file, and make modifications to suit your environment.

    ```shell
    vi .env
    ```

6. Start Snipe-IT in the background.

    ```shell
    docker-compose up -d
    ```

### Upgrading

**Warning: the upgrade process will immediately stop and upgrade the current production environment. The application stack will be unavailable while it is being upgraded.**

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/snipeit
    ```

2. Run the upgrade script.

    ```shell
    ./scripts/app-upgrade.sh
    ```

### Running a one-time manual backup

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/snipeit
    ```

2. Run the backup script.

    ```shell
    docker-compose exec cron app-backup
    ```

### Restoring from a backup

**Warning: the restoration process will immediately stop and delete the current production environment. You will not be asked to save any data before the restoration process starts.**

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/snipeit
    ```

2. List the available files in the `backups` directory.

    ```shell
    ls -l backups
    ```

3. Specify a file to restore in the following format:

    ```shell
    ./scripts/app-restore.sh <backup-file-name>
    ```

    For example:

    ```shell
    ./scripts/app-restore.sh 20170501T031500+0000.tar.gz
    ```

### Uninstalling

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/snipeit
    ```

2. Remove the application stack.

    ```shell
    docker-compose down
    ```

3. Delete the repo. **Warning: this step is optional. If you delete the repo, all of your Snipe-IT data, including backups, will be lost.**

    ```shell
    rm -rf /srv/docker/snipeit
    ```

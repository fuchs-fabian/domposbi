# `domposbi`: Backup Docker Compose projects with ease

<p align="center">
  <a href="./LICENSE">
    <img alt="GPL-3.0 License" src="https://img.shields.io/badge/GitHub-GPL--3.0-informational">
  </a>
</p>

<div align="center">
  <a href="https://github.com/fuchs-fabian/domposbi">
    <img src="https://github-readme-stats.vercel.app/api/pin/?username=fuchs-fabian&repo=domposbi&theme=holi&hide_border=true&border_radius=10" alt="Repository domposbi"/>
  </a>
</div>

## Description

Docker Compose projects can be easily backed up with `domposbi`. The project is based on `simbashlog` and [`domposy`](https://github.com/fuchs-fabian/domposy).

<div align="left">
  <a href="https://github.com/fuchs-fabian/domposy">
    <img src="https://github-readme-stats.vercel.app/api/pin/?username=fuchs-fabian&repo=domposy&theme=holi&hide_border=true&border_radius=10" alt="Repository domposy"/>
  </a>
</div>

> **Important**: The backups do not work with Docker volumes, but only with Docker bind mounts, because the folders of the Docker Compose projects are backed up directly. This means that only the data in the project folders are backed up.

**Examples for Docker Compose files**:

<a href="https://github.com/fuchs-fabian/docker-compose-files">
  <img src="https://github-readme-stats.vercel.app/api/pin/?username=fuchs-fabian&repo=docker-compose-files&theme=holi&hide_border=true&border_radius=10" alt="Repository docker-compose-files"/>
</a>

> **Attention**: The container needs access to the Docker socket. This is necessary to be able to back up the Docker Compose projects!

## Getting Started

The easiest way is to download and run the [`install.sh`](./install.sh) script.

It will guide you through the installation process and create the necessary files and directories so that you don't have to worry about anything setting up manually.

First, go to the directory where you want to install the container.

The following command will download the installation script, make it executable, execute it and then delete it:

```shell
wget -q -O install.sh https://raw.githubusercontent.com/fuchs-fabian/domposbi/refs/heads/main/install.sh && \
chmod +x install.sh && \
./install.sh && \
rm install.sh
```

As the [simbashlog-notifier](https://github.com/fuchs-fabian/simbashlog-notifiers) does not work straight away, the container must be shut down and then the configuration file under `volumes/config/` must be adapted.

If a notifier is used that requires additional files, these must be created on the host and mounted. Alternatively, the files can also be created in the container if the corresponding bind mounts have been set beforehand.

If the cronjob schedule or other settings are to be adjusted, the Docker container must be shut down briefly and the `.env` file adjusted:

```shell
docker compose down
```

```shell
nano .env
```

The `.env` file should look like this:

```plain
DOCKER_COMPOSE_PROJECTS_DIR='/path/to/your/docker-compose-projects'
BACKUP_DIR='/path/to/your/backup/directory'

CRON_SCHEDULE=*/10 * * * *
GIT_REPO_URL_FOR_SIMBASHLOG_NOTIFIER=''

# This should not be changed, if 'domposbi' is also in the Docker Compose projects directory!
KEYWORD_TO_EXCLUDE_FROM_BACKUP='domposbi'

KEEP_BACKUPS=10

# Optional
ENABLE_DEBUG_MODE=false
ENABLE_DRY_RUN=false
```

As the log files are mounted on the host by default, the files could become very large in the long term. The log files should therefore be deleted from time to time.

The log files are located under `volumes/logs/`.

## Bugs, Suggestions, Feedback, and Needed Support

> If you have any bugs, suggestions or feedback, feel free to create an issue or create a pull request with your changes.

## Support `simbashlog`

If you like `simbashlog`'s ecosystem, you think it is useful and saves you a lot of work and nerves and lets you sleep better, please give it a star and consider donating.

<a href="https://www.paypal.com/donate/?hosted_button_id=4G9X8TDNYYNKG" target="_blank">
  <!--
    https://github.com/stefan-niedermann/paypal-donate-button
  -->
  <img src="https://raw.githubusercontent.com/stefan-niedermann/paypal-donate-button/master/paypal-donate-button.png" style="height: 90px; width: 217px;" alt="Donate with PayPal"/>
</a>

---

> This repository uses [`simbashlog`](https://github.com/fuchs-fabian/simbashlog) ([LICENSE](https://github.com/fuchs-fabian/simbashlog/blob/main/LICENSE)).
>
> *Copyright (C) 2024 Fabian Fuchs*

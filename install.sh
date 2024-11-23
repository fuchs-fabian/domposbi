#!/usr/bin/env sh

REPO_URL="https://github.com/fuchs-fabian/domposbi.git"
BRANCH_NAME="main"

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░              GENERAL UTILS               ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

abort() {
    echo "ERROR: $1"
    echo "Aborting..."
    exit 1
}

check_command() {
    cmd="$1"

    echo "Checking if the '$cmd' command is available..."
    command -v "$cmd" >/dev/null 2>&1 ||
        abort "The '$cmd' command is not available. Please install it and try again."
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░               PREPARATIONS               ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

PROJECT_NAME=$(basename $REPO_URL .git)

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║               CHECK COMMANDS               ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

check_command "git"
check_command "docker"

echo "Checking if 'docker compose' is available..."
docker compose version >/dev/null 2>&1 ||
    abort "The 'docker compose' command is not available"

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║         CHECK FOR PROJECT ARTIFACTS        ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

if [ -d "$PROJECT_NAME" ]; then
    echo
    echo "The directory '$PROJECT_NAME' already exists. Remove it? (y/n)"
    read -r REMOVE_DIR
    if [ "$REMOVE_DIR" = "y" ]; then
        rm -rf "$PROJECT_NAME" ||
            abort "Failed to remove the directory '$PROJECT_NAME'"
    else
        abort "The install script cannot continue. You have to set up manually!"
    fi
    echo
fi

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░               INSTALLATION               ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

echo
echo "Installing '$PROJECT_NAME'..."

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║             CLONE REPOSITORY               ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

if [ -z "$BRANCH_NAME" ]; then BRANCH_NAME="main"; fi

echo "Cloning '$REPO_URL' from branch '$BRANCH_NAME'..."

git clone --branch "$BRANCH_NAME" "$REPO_URL" ||
    abort "Failed to clone '$REPO_URL' from branch '$BRANCH_NAME'"

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║             MOVE TO PROJECT DIR            ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

cd "$PROJECT_NAME" ||
    abort "The directory '$PROJECT_NAME' does not exist. Something went wrong."

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║          CREATE THE '.env' FILE            ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

echo "Setting up the '.env' file..."

CRON_JOB_MINUTES=10
CRON_SCHEDULE="*/$CRON_JOB_MINUTES * * * *"
ENABLE_DEBUG_MODE=false
ENABLE_DRY_RUN=false

echo
echo "Enter the projects directory for the Docker Compose projects:"
read -r DOCKER_COMPOSE_PROJECTS_DIR ||
    abort "Failed to read the directory for the Docker Compose projects"
echo

echo
echo "Enter the backup directory:"
read -r BACKUP_DIR ||
    abort "Failed to read the backup directory"
echo

echo
echo "Enter the git repo url for the 'simbashlog' notifier (press enter if not needed):"
read -r GIT_REPO_URL_FOR_SIMBASHLOG_NOTIFIER ||
    abort "Failed to read the git repo url for the 'simbashlog' notifier"
echo

echo
echo "Enter the number of backups to keep ('all' or a number):"
read -r KEEP_BACKUPS ||
    abort "Failed to read the value for backups to keep"
echo

echo "Creating the '.env' file..."
cat <<EOF >.env
DOCKER_COMPOSE_PROJECTS_DIR='$DOCKER_COMPOSE_PROJECTS_DIR'
BACKUP_DIR='$BACKUP_DIR'

CRON_SCHEDULE=$CRON_SCHEDULE
GIT_REPO_URL_FOR_SIMBASHLOG_NOTIFIER='$GIT_REPO_URL_FOR_SIMBASHLOG_NOTIFIER'

# This should not be changed, if '$PROJECT_NAME' is also in the Docker Compose projects directory!
KEYWORD_TO_EXCLUDE_FROM_BACKUP='$PROJECT_NAME'

KEEP_BACKUPS=$KEEP_BACKUPS

# Optional
ENABLE_DEBUG_MODE=$ENABLE_DEBUG_MODE
ENABLE_DRY_RUN=$ENABLE_DRY_RUN
EOF

cat .env ||
    abort "Failed to create the '.env' file"

echo "The cron job will run every $CRON_JOB_MINUTES minutes."

if [ -n "$GIT_REPO_URL_FOR_SIMBASHLOG_NOTIFIER" ]; then
    echo "The git repo url for the 'simbashlog' notifier is set to '$GIT_REPO_URL_FOR_SIMBASHLOG_NOTIFIER'"
else
    echo "The git repo url for the 'simbashlog' notifier is not set"
fi
echo

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                  CLEANUP                   ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │               GIT ARTIFACTS                │
# └─────────────────────┴──────────────────────┘

echo "Removing unnecessary git artifacts..."

rm -rf .git ||
    abort "Failed to remove the '.git' directory from the project directory"

rm install.sh ||
    abort "Failed to remove the install script from the project directory"

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║             FINAL EXECUTIONS               ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

echo
echo "Do you want to run the Docker container for '$PROJECT_NAME' now? (y/N)"
read -r RUN_CONTAINER
if [ "$RUN_CONTAINER" = "y" ]; then
    echo "Running the Docker container for '$PROJECT_NAME'..."
    docker compose up -d ||
        abort "Failed to run the Docker container"
fi

echo "The installation for '$PROJECT_NAME' is complete"
echo
echo "INFO: If a 'simbashlog' notifier is set and you have to configure it, you have to shut down the container, adjust the configuration and restart the container"

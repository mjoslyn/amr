#!/bin/bash

# WP-CLI script to pull database from production to development (Docker version)
#
# Usage: ./pull-wp.sh [OPTIONS]
#
# Options:
#   --db-pull             Pull database from production
#   --local-file <path>   Use a local SQL file instead of pulling from production
#   --config-only         Only sync WordPress config (security keys)
#   --pull-plugins        Only sync plugins from production
#   --pull-themes         Only sync themes from production
#   --pull-uploads        Only sync media/uploads from production
#   --days <number>       Only sync uploads modified in last N days (use with --pull-uploads or --full)
#   --fix-urls            Only fix URLs in database to point to local
#   --full                Do everything (DB + plugins + themes + media + URLs + keys)
#
# Examples:
#   ./pull-wp.sh                              # Show this help message
#   ./pull-wp.sh --db-pull                    # Pull database from production
#   ./pull-wp.sh --local-file backup.sql      # Import from local file
#   ./pull-wp.sh --config-only                # Only sync security keys
#   ./pull-wp.sh --pull-plugins               # Only sync plugins
#   ./pull-wp.sh --pull-themes                # Only sync themes
#   ./pull-wp.sh --pull-uploads               # Only sync media/uploads
#   ./pull-wp.sh --pull-uploads --days 7      # Only sync uploads from last 7 days
#   ./pull-wp.sh --fix-urls                   # Only fix URLs to local
#   ./pull-wp.sh --full                       # Do everything

set -e

# Parse arguments
DB_PULL=false
LOCAL_FILE=""
CONFIG_ONLY=false
PULL_PLUGINS=false
PULL_THEMES=false
PULL_UPLOADS=false
DAYS_BACK=""
FIX_URLS=false
FULL=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --db-pull)
            DB_PULL=true
            shift
            ;;
        --local-file)
            LOCAL_FILE="$2"
            DB_PULL=true
            shift 2
            ;;
        --config-only)
            CONFIG_ONLY=true
            shift
            ;;
        --pull-plugins)
            PULL_PLUGINS=true
            shift
            ;;
        --pull-themes)
            PULL_THEMES=true
            shift
            ;;
        --pull-uploads)
            PULL_UPLOADS=true
            shift
            ;;
        --days)
            DAYS_BACK="$2"
            shift 2
            ;;
        --fix-urls)
            FIX_URLS=true
            shift
            ;;
        --full)
            FULL=true
            DB_PULL=true
            PULL_PLUGINS=true
            PULL_THEMES=true
            PULL_UPLOADS=true
            FIX_URLS=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --db-pull             Pull database from production"
            echo "  --local-file <path>   Use a local SQL file instead of pulling from production"
            echo "  --config-only         Only sync WordPress config (security keys)"
            echo "  --pull-plugins        Only sync plugins from production"
            echo "  --pull-themes         Only sync themes from production"
            echo "  --pull-uploads        Only sync media/uploads from production"
            echo "  --days <number>       Only sync uploads modified in last N days (use with --pull-uploads or --full)"
            echo "  --fix-urls            Only fix URLs in database to point to local"
            echo "  --full                Do everything (DB + plugins + themes + media + URLs + keys)"
            echo ""
            echo "Examples:"
            echo "  $0                              # Show this help message"
            echo "  $0 --db-pull                    # Pull database from production"
            echo "  $0 --local-file backup.sql      # Import from local file"
            echo "  $0 --config-only                # Only sync security keys"
            echo "  $0 --pull-plugins               # Only sync plugins"
            echo "  $0 --pull-themes                # Only sync themes"
            echo "  $0 --pull-uploads               # Only sync media/uploads"
            echo "  $0 --pull-uploads --days 7      # Only sync uploads from last 7 days"
            echo "  $0 --fix-urls                   # Only fix URLs to local"
            echo "  $0 --full                       # Do everything"
            exit 1
            ;;
    esac
done

# Show help if no arguments provided
if [ "$DB_PULL" = false ] && [ "$CONFIG_ONLY" = false ] && [ "$PULL_PLUGINS" = false ] && [ "$PULL_THEMES" = false ] && [ "$PULL_UPLOADS" = false ] && [ "$FIX_URLS" = false ] && [ "$FULL" = false ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --db-pull             Pull database from production"
    echo "  --local-file <path>   Use a local SQL file instead of pulling from production"
    echo "  --config-only         Only sync WordPress config (security keys)"
    echo "  --pull-plugins        Only sync plugins from production"
    echo "  --pull-themes         Only sync themes from production"
    echo "  --pull-uploads        Only sync media/uploads from production"
    echo "  --days <number>       Only sync uploads modified in last N days (use with --pull-uploads or --full)"
    echo "  --fix-urls            Only fix URLs in database to point to local"
    echo "  --full                Do everything (DB + plugins + themes + media + URLs + keys)"
    echo ""
    echo "Examples:"
    echo "  $0                              # Show this help message"
    echo "  $0 --db-pull                    # Pull database from production"
    echo "  $0 --local-file backup.sql      # Import from local file"
    echo "  $0 --config-only                # Only sync security keys"
    echo "  $0 --pull-plugins               # Only sync plugins"
    echo "  $0 --pull-themes                # Only sync themes"
    echo "  $0 --pull-uploads               # Only sync media/uploads"
    echo "  $0 --pull-uploads --days 7      # Only sync uploads from last 7 days"
    echo "  $0 --fix-urls                   # Only fix URLs to local"
    echo "  $0 --full                       # Do everything"
    exit 0
fi

# ===========================
# CONFIGURATION
# ===========================
PROD_SSH="robotofthefuture@alleganymountainresort.com"     # SSH connection
PROD_PATH="public_html"  # Path to WordPress on production (relative to home)
PROD_URL="https://www.alleganymountainresort.com"   # Production URL for search-replace
DOCKER_COMPOSE="docker-compose"              # docker-compose command
WORDPRESS_CONTAINER="wordpress"              # WordPress service name
DB_CONTAINER="db"                            # MySQL service name
DB_NAME="wordpress"                          # Database name
DB_USER="wordpress"                          # Database user
DB_PASS="wordpress_password"                 # Database password
CONTAINER_WP_PATH="/var/www/html"           # WordPress path inside container
SQL_DIR="../sql"                             # Local directory for SQL files
LOCAL_URL="https://www.alleganymountainresort.local:8443"     # Your local development URL

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Timestamp for backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
START_TIME=$(date +%s)

if [ "$FULL" = true ]; then
    echo -e "${YELLOW}======================================${NC}"
    echo -e "${YELLOW}Full Sync Script Started (DB + Plugins + Themes + Media + URLs)${NC}"
    echo -e "${YELLOW}======================================${NC}"
elif [ "$DB_PULL" = true ]; then
    echo -e "${YELLOW}======================================${NC}"
    echo -e "${YELLOW}Database Pull Script Started${NC}"
    echo -e "${YELLOW}======================================${NC}"
elif [ "$PULL_UPLOADS" = true ]; then
    echo -e "${YELLOW}======================================${NC}"
    echo -e "${YELLOW}Uploads Sync Script Started${NC}"
    echo -e "${YELLOW}======================================${NC}"
elif [ "$FIX_URLS" = true ]; then
    echo -e "${YELLOW}======================================${NC}"
    echo -e "${YELLOW}URL Fix Script Started${NC}"
    echo -e "${YELLOW}======================================${NC}"
elif [ "$PULL_PLUGINS" = true ]; then
    echo -e "${YELLOW}======================================${NC}"
    echo -e "${YELLOW}Plugin Sync Script Started${NC}"
    echo -e "${YELLOW}======================================${NC}"
elif [ "$PULL_THEMES" = true ]; then
    echo -e "${YELLOW}======================================${NC}"
    echo -e "${YELLOW}Theme Sync Script Started${NC}"
    echo -e "${YELLOW}======================================${NC}"
elif [ "$CONFIG_ONLY" = true ]; then
    echo -e "${YELLOW}======================================${NC}"
    echo -e "${YELLOW}Config Sync Script Started${NC}"
    echo -e "${YELLOW}======================================${NC}"
fi
echo -e "${BLUE}Timestamp: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e ""
echo -e "${CYAN}Configuration:${NC}"
echo -e "${BLUE}  Production SSH: ${PROD_SSH}${NC}"
echo -e "${BLUE}  Production Path: ${PROD_PATH}${NC}"
echo -e "${BLUE}  Local URL: ${LOCAL_URL}${NC}"
echo -e "${BLUE}  Docker Compose: ${DOCKER_COMPOSE}${NC}"
echo -e "${BLUE}  WordPress Container: ${WORDPRESS_CONTAINER}${NC}"
if [ "$DB_PULL" = true ] || [ "$FULL" = true ]; then
    echo -e "${BLUE}  Database Container: ${DB_CONTAINER}${NC}"
    echo -e "${BLUE}  Database Name: ${DB_NAME}${NC}"
    echo -e "${BLUE}  SQL Directory: ${SQL_DIR}${NC}"
fi
echo -e ""

if [ "$DB_PULL" = true ] || [ "$FULL" = true ]; then
    # Create SQL directory if it doesn't exist
    echo -e "${GREEN}[1/9] Creating SQL directory...${NC}"
    mkdir -p "$SQL_DIR"
    echo -e "${BLUE}  Directory created/verified: ${SQL_DIR}${NC}"
    echo -e ""

    # Check if Docker containers are running
    echo -e "${GREEN}[2/9] Checking Docker containers...${NC}"
    if ! $DOCKER_COMPOSE ps | grep -q "$WORDPRESS_CONTAINER"; then
        echo -e "${RED}Error: WordPress container is not running${NC}"
        echo "Start your containers with: docker-compose up -d"
        exit 1
    fi
    echo -e "${BLUE}  WordPress container: Running ✓${NC}"

    if ! $DOCKER_COMPOSE ps | grep -q "$DB_CONTAINER"; then
        echo -e "${RED}Error: Database container is not running${NC}"
        exit 1
    fi
    echo -e "${BLUE}  Database container: Running ✓${NC}"
    echo -e ""
elif [ "$CONFIG_ONLY" = true ] || [ "$PULL_PLUGINS" = true ] || [ "$PULL_THEMES" = true ] || [ "$FIX_URLS" = true ]; then
    # Just check WordPress container for config-only, plugin sync, or fix-urls mode
    echo -e "${GREEN}[1/2] Checking Docker containers...${NC}"
    if ! $DOCKER_COMPOSE ps | grep -q "$WORDPRESS_CONTAINER"; then
        echo -e "${RED}Error: WordPress container is not running${NC}"
        echo "Start your containers with: docker-compose up -d"
        exit 1
    fi
    echo -e "${BLUE}  WordPress container: Running ✓${NC}"
    echo -e ""
fi

# Setup WP-CLI in container (only needed for DB operations and config-only)
if [ "$PULL_PLUGINS" = true ] || [ "$PULL_THEMES" = true ]; then
    # Skip WP-CLI setup for plugin/theme sync only - we don't need it
    :
elif [ "$FIX_URLS" = true ] && [ "$FULL" = false ]; then
    # Skip WP-CLI setup for fix-urls only - will be set up later in the fix-urls section
    :
elif [ "$DB_PULL" = true ] || [ "$FULL" = true ]; then
    echo -e "${GREEN}[2b/9] Setting up WP-CLI...${NC}"
elif [ "$CONFIG_ONLY" = true ]; then
    echo -e "${GREEN}[1b/2] Setting up WP-CLI...${NC}"
fi

if [ "$DB_PULL" = true ] || [ "$CONFIG_ONLY" = true ] || [ "$FULL" = true ]; then
WP_CLI_PATH="/tmp/wp-cli.phar"
WP_CLI="php $WP_CLI_PATH --allow-root"

# Check if WP-CLI exists in container, if not download it
if ! $DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER test -f "$WP_CLI_PATH" 2>/dev/null; then
    echo -e "${BLUE}  WP-CLI not found in container, downloading...${NC}"
    $DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER sh -c "curl -o $WP_CLI_PATH https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x $WP_CLI_PATH"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  WP-CLI downloaded successfully ✓${NC}"
    else
        echo -e "${RED}Error: Failed to download WP-CLI${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}  WP-CLI found in container cache ✓${NC}"
fi

# Check WP-CLI version in container
WP_CLI_VERSION=$($DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER $WP_CLI --version 2>/dev/null || echo "Unknown")
echo -e "${BLUE}  WP-CLI version: ${WP_CLI_VERSION}${NC}"
echo -e "${BLUE}  WP-CLI path: ${WP_CLI_PATH}${NC}"
echo -e ""
fi # End of WP-CLI setup

# Skip database steps unless doing DB pull or full sync
if [ "$DB_PULL" = false ] && [ "$FULL" = false ]; then
    # Jump to other operations - all database steps will be skipped
    :
else
# Validate local file if provided
if [ -n "$LOCAL_FILE" ]; then
    echo -e "${GREEN}[2c/9] Validating local SQL file...${NC}"

    if [ ! -f "$LOCAL_FILE" ]; then
        echo -e "${RED}Error: File not found: $LOCAL_FILE${NC}"
        exit 1
    fi

    # Check if it's a valid SQL file (basic check)
    if ! head -n 20 "$LOCAL_FILE" | grep -qi "SQL\|INSERT\|CREATE\|DROP"; then
        echo -e "${YELLOW}Warning: File doesn't appear to be a SQL file${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    FILE_SIZE=$(ls -lh "$LOCAL_FILE" | awk '{print $5}')
    echo -e "${BLUE}  Local file: $LOCAL_FILE${NC}"
    echo -e "${BLUE}  File size: ${FILE_SIZE}${NC}"
    echo -e "${GREEN}  File validated ✓${NC}"
    echo -e ""
fi

# Backup current local database
echo -e "${GREEN}[3/9] Backing up current local database...${NC}"
echo -e "${BLUE}  Using mysqldump from database container${NC}"
BACKUP_START=$(date +%s)
$DOCKER_COMPOSE exec -T $DB_CONTAINER mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > "$SQL_DIR/backup-local-${TIMESTAMP}.sql" 2>&1 | grep -v "mysqldump: \[Warning\]" || true
BACKUP_END=$(date +%s)
BACKUP_TIME=$((BACKUP_END - BACKUP_START))
BACKUP_SIZE=$(ls -lh "$SQL_DIR/backup-local-${TIMESTAMP}.sql" | awk '{print $5}')
echo -e "${BLUE}  Backup saved: $SQL_DIR/backup-local-${TIMESTAMP}.sql${NC}"
echo -e "${BLUE}  Backup size: ${BACKUP_SIZE}${NC}"
echo -e "${BLUE}  Time taken: ${BACKUP_TIME}s${NC}"
echo -e ""

if [ -n "$LOCAL_FILE" ]; then
    # Use local file
    echo -e "${GREEN}[4/9] Using local SQL file (skipping production export)...${NC}"
    echo -e "${BLUE}  Copying to working directory...${NC}"
    COPY_START=$(date +%s)
    cp "$LOCAL_FILE" "$SQL_DIR/amr.sql"
    COPY_END=$(date +%s)
    COPY_TIME=$((COPY_END - COPY_START))

    EXPORT_SIZE=$(ls -lh "$SQL_DIR/amr.sql" | awk '{print $5}')
    echo -e "${BLUE}  Copy complete: ${EXPORT_SIZE}${NC}"
    echo -e "${BLUE}  Time taken: ${COPY_TIME}s${NC}"
    echo -e ""

    # Skip step 5 (getting production URL) since we already have it hardcoded
    echo -e "${GREEN}[5/9] Using hardcoded production URL...${NC}"
    echo -e "${BLUE}  Production URL: ${PROD_URL}${NC}"
    echo -e ""
else
    # Export database from production
    echo -e "${GREEN}[4/9] Exporting production database...${NC}"
    echo -e "${BLUE}  Connecting to: ${PROD_SSH}${NC}"
    echo -e "${BLUE}  Remote path: ${PROD_PATH}${NC}"
    echo -e "${BLUE}  Running: wp db export - --add-drop-table${NC}"
    EXPORT_START=$(date +%s)

    # Start export in background
    ssh $PROD_SSH "cd $PROD_PATH && wp db export - --add-drop-table" > "$SQL_DIR/amr.sql" &
    EXPORT_PID=$!

    # Progress indicator with spinner
    SPINNER='|/-\'
    SPIN_INDEX=0
    ELAPSED=0

    while kill -0 $EXPORT_PID 2>/dev/null; do
        if [ -f "$SQL_DIR/amr.sql" ]; then
            SIZE=$(ls -lh "$SQL_DIR/amr.sql" | awk '{print $5}')
        else
            SIZE="0B"
        fi
        printf "\r${BLUE}  ${SPINNER:SPIN_INDEX:1} Downloading... ${SIZE} (${ELAPSED}s)${NC}"
        SPIN_INDEX=$(( (SPIN_INDEX + 1) % 4 ))
        ELAPSED=$((ELAPSED + 1))
        sleep 1
    done

    wait $EXPORT_PID
    EXPORT_END=$(date +%s)
    EXPORT_TIME=$((EXPORT_END - EXPORT_START))

    printf "\r${GREEN}  ✓ Download complete!                           ${NC}\n"

    if [ ! -s "$SQL_DIR/amr.sql" ]; then
        echo -e "${RED}Error: Failed to export production database${NC}"
        exit 1
    fi

    EXPORT_SIZE=$(ls -lh "$SQL_DIR/amr.sql" | awk '{print $5}')
    echo -e "${BLUE}  Export size: ${EXPORT_SIZE}${NC}"
    echo -e "${BLUE}  Time taken: ${EXPORT_TIME}s${NC}"
    echo -e "${GREEN}  Production database exported successfully ✓${NC}"
    echo -e ""

    # Get production URL from remote
    echo -e "${GREEN}[5/9] Getting production URL from server...${NC}"
    PROD_URL_FROM_SERVER=$(ssh $PROD_SSH "cd $PROD_PATH && wp option get siteurl" 2>/dev/null || echo "")

    if [ -n "$PROD_URL_FROM_SERVER" ]; then
        PROD_URL="$PROD_URL_FROM_SERVER"
        echo -e "${BLUE}  Production URL (from server): ${PROD_URL}${NC}"
    else
        echo -e "${YELLOW}  Warning: Could not fetch URL from server, using default${NC}"
        echo -e "${BLUE}  Production URL (default): ${PROD_URL}${NC}"
    fi
    echo -e ""
fi

# Import database to local MySQL container
echo -e "${GREEN}[6/9] Importing database to local...${NC}"
echo -e "${BLUE}  Database: ${DB_NAME}${NC}"
echo -e "${BLUE}  User: ${DB_USER}${NC}"
echo -e "${BLUE}  Container: ${DB_CONTAINER}${NC}"
IMPORT_START=$(date +%s)
$DOCKER_COMPOSE exec -T $DB_CONTAINER mysql -u$DB_USER -p$DB_PASS $DB_NAME < "$SQL_DIR/amr.sql" 2>&1 | grep -v "mysql: \[Warning\]" || true
IMPORT_END=$(date +%s)
IMPORT_TIME=$((IMPORT_END - IMPORT_START))
echo -e "${BLUE}  Time taken: ${IMPORT_TIME}s${NC}"
echo -e "${GREEN}  Database imported successfully ✓${NC}"
echo -e ""

# Search and replace URLs - only during full sync, not for db-pull alone
if [ "$FULL" = true ]; then
    echo -e "${GREEN}[7/9] Replacing URLs: $PROD_URL -> $LOCAL_URL${NC}"
    REPLACE_OUTPUT=$($DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER $WP_CLI search-replace "$PROD_URL" "$LOCAL_URL" --path="$CONTAINER_WP_PATH" --all-tables 2>&1)
    echo -e "${BLUE}${REPLACE_OUTPUT}${NC}"
    echo -e ""

    # Also handle https to http if needed
    if [[ $PROD_URL == https://* ]]; then
        PROD_URL_HTTPS="${PROD_URL}"
        PROD_URL_HTTP="${PROD_URL/https:/http:}"
        echo -e "${GREEN}[7b/9] Additional replacement for HTTPS variant...${NC}"
        echo -e "${BLUE}  Replacing: $PROD_URL_HTTPS -> $LOCAL_URL${NC}"
        REPLACE_HTTPS_OUTPUT=$($DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER $WP_CLI search-replace "$PROD_URL_HTTPS" "$LOCAL_URL" --path="$CONTAINER_WP_PATH" --all-tables 2>&1)
        echo -e "${BLUE}${REPLACE_HTTPS_OUTPUT}${NC}"
        echo -e ""
    fi
fi
fi # End of DB_PULL block

# Sync WordPress security keys from production to local (for config-only, full, or db-pull)
if [ "$CONFIG_ONLY" = true ] || [ "$FULL" = true ] || [ "$DB_PULL" = true ]; then
    if [ "$FULL" = true ]; then
        echo -e "${GREEN}[7c/9] Syncing security keys from production...${NC}"
    else
        echo -e "${GREEN}[2/2] Syncing security keys from production...${NC}"
    fi
    echo -e "${BLUE}  This ensures login sessions work correctly${NC}"

    # Array of security constants to sync
    SECURITY_KEYS=("AUTH_KEY" "SECURE_AUTH_KEY" "LOGGED_IN_KEY" "NONCE_KEY" "AUTH_SALT" "SECURE_AUTH_SALT" "LOGGED_IN_SALT" "NONCE_SALT")

    KEYS_SYNCED=0
    KEYS_FAILED=0

    for KEY in "${SECURITY_KEYS[@]}"; do
        # Fetch key value from production
        KEY_VALUE=$(ssh $PROD_SSH "cd $PROD_PATH && wp config get $KEY" 2>/dev/null || echo "")

        if [ -n "$KEY_VALUE" ] && [ "$KEY_VALUE" != "false" ]; then
            # Update local wp-config.php
            $DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER $WP_CLI config set "$KEY" "$KEY_VALUE" --path="$CONTAINER_WP_PATH" 2>/dev/null
            if [ $? -eq 0 ]; then
                KEYS_SYNCED=$((KEYS_SYNCED + 1))
                echo -e "${BLUE}  Synced: $KEY${NC}"
            else
                KEYS_FAILED=$((KEYS_FAILED + 1))
                echo -e "${YELLOW}  Warning: Failed to update $KEY${NC}"
            fi
        else
            KEYS_FAILED=$((KEYS_FAILED + 1))
            echo -e "${YELLOW}  Warning: Could not fetch $KEY from production${NC}"
        fi
    done

    if [ $KEYS_SYNCED -eq 8 ]; then
        echo -e "${GREEN}  All security keys synced successfully (8/8) ✓${NC}"
    elif [ $KEYS_SYNCED -gt 0 ]; then
        echo -e "${YELLOW}  Partially synced: ${KEYS_SYNCED}/8 keys updated${NC}"
        echo -e "${YELLOW}  You may need to reset your password if login fails${NC}"
    else
        echo -e "${RED}  Warning: No keys could be synced${NC}"
        echo -e "${RED}  You will likely need to reset your password${NC}"
    fi
    echo -e ""
fi # End of skip security keys for plugin sync mode

# Sync plugins from production if requested
if [ "$PULL_PLUGINS" = true ] || [ "$FULL" = true ]; then
    echo -e "${GREEN}[1/1] Syncing plugins from production...${NC}"

    echo -e "${BLUE}  Creating temporary directory for plugin sync...${NC}"
    PLUGINS_TEMP_DIR="/tmp/wp-plugins-sync-$$"
    mkdir -p "$PLUGINS_TEMP_DIR"

    # Download plugins directory from production
    echo -e "${BLUE}  Downloading plugins from production via rsync...${NC}"
    SYNC_START=$(date +%s)
    rsync -avz --progress \
        --exclude='*/cache/*' \
        --exclude='*/tmp/*' \
        "$PROD_SSH:$PROD_PATH/wp-content/plugins/" \
        "$PLUGINS_TEMP_DIR/" 2>&1 | grep -v "sending incremental" || true
    SYNC_END=$(date +%s)
    SYNC_TIME=$((SYNC_END - SYNC_START))

    echo -e "${BLUE}  Copying plugins to local WordPress container...${NC}"
    docker cp "$PLUGINS_TEMP_DIR/." "$(docker-compose ps -q $WORDPRESS_CONTAINER):$CONTAINER_WP_PATH/wp-content/plugins/"

    echo -e "${BLUE}  Setting correct permissions...${NC}"
    $DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER chown -R www-data:www-data "$CONTAINER_WP_PATH/wp-content/plugins" 2>/dev/null || true

    echo -e "${BLUE}  Cleaning up temporary files...${NC}"
    rm -rf "$PLUGINS_TEMP_DIR"

    echo -e "${BLUE}  Time taken: ${SYNC_TIME}s${NC}"
    echo -e "${GREEN}  Plugins synced successfully ✓${NC}"
    echo -e ""
fi

# Sync themes from production if requested
if [ "$PULL_THEMES" = true ] || [ "$FULL" = true ]; then
    echo -e "${GREEN}[1/1] Syncing themes from production...${NC}"

    echo -e "${BLUE}  Creating temporary directory for theme sync...${NC}"
    THEMES_TEMP_DIR="/tmp/wp-themes-sync-$$"
    mkdir -p "$THEMES_TEMP_DIR"

    # Download themes directory from production
    echo -e "${BLUE}  Downloading themes from production via rsync...${NC}"
    SYNC_START=$(date +%s)
    rsync -avz --progress \
        --exclude='*/cache/*' \
        --exclude='*/tmp/*' \
        "$PROD_SSH:$PROD_PATH/wp-content/themes/" \
        "$THEMES_TEMP_DIR/" 2>&1 | grep -v "sending incremental" || true
    SYNC_END=$(date +%s)
    SYNC_TIME=$((SYNC_END - SYNC_START))

    echo -e "${BLUE}  Copying themes to local WordPress container...${NC}"
    docker cp "$THEMES_TEMP_DIR/." "$(docker-compose ps -q $WORDPRESS_CONTAINER):$CONTAINER_WP_PATH/wp-content/themes/"

    echo -e "${BLUE}  Setting correct permissions...${NC}"
    $DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER chown -R www-data:www-data "$CONTAINER_WP_PATH/wp-content/themes" 2>/dev/null || true

    echo -e "${BLUE}  Cleaning up temporary files...${NC}"
    rm -rf "$THEMES_TEMP_DIR"

    echo -e "${BLUE}  Time taken: ${SYNC_TIME}s${NC}"
    echo -e "${GREEN}  Themes synced successfully ✓${NC}"
    echo -e ""
fi

# Sync media/uploads from production if requested
if [ "$PULL_UPLOADS" = true ] || [ "$FULL" = true ]; then
    echo -e "${GREEN}Syncing media/uploads from production...${NC}"

    # Define local uploads path (relative to script location)
    LOCAL_UPLOADS_PATH="./wp-content/uploads"

    # Verify local uploads directory exists
    if [ ! -d "$LOCAL_UPLOADS_PATH" ]; then
        echo -e "${RED}Error: Local uploads directory not found: $LOCAL_UPLOADS_PATH${NC}"
        echo -e "${YELLOW}Make sure you're running this script from the WordPress root directory${NC}"
        exit 1
    fi

    echo -e "${BLUE}  Local path: $(cd "$LOCAL_UPLOADS_PATH" && pwd)${NC}"
    echo -e "${BLUE}  Production: $PROD_SSH:$PROD_PATH/wp-content/uploads/${NC}"
    echo -e "${BLUE}  Download method: rsync with compression${NC}"
    echo -e ""

    # Get initial size of local uploads directory
    UPLOADS_SIZE_BEFORE=$(du -sh "$LOCAL_UPLOADS_PATH" 2>/dev/null | awk '{print $1}')
    echo -e "${BLUE}  Current local uploads size: ${UPLOADS_SIZE_BEFORE}${NC}"
    echo -e ""

    # Download uploads directory from production using rsync
    echo -e "${BLUE}  Starting rsync (this may take several minutes for large uploads)...${NC}"
    echo -e "${YELLOW}  Note: Files will be synced from newest to oldest${NC}"
    if [ -n "$DAYS_BACK" ]; then
        echo -e "${YELLOW}  Note: Only syncing files modified in the last ${DAYS_BACK} days${NC}"
    fi
    echo -e "${YELLOW}  Note: Only new/changed files will be downloaded${NC}"
    echo -e ""

    SYNC_START=$(date +%s)

    # Create temp file for sorted file list
    FILES_LIST="/tmp/uploads-files-list-$$"

    # Build find command with optional -mtime filter
    MTIME_FILTER=""
    if [ -n "$DAYS_BACK" ]; then
        MTIME_FILTER="-mtime -${DAYS_BACK}"
    fi

    # Get file list from production sorted by modification time (newest first)
    if [ -n "$DAYS_BACK" ]; then
        echo -e "${BLUE}  Building sorted file list from production (last ${DAYS_BACK} days)...${NC}"
    else
        echo -e "${BLUE}  Building sorted file list from production...${NC}"
    fi

    ssh $PROD_SSH "cd $PROD_PATH/wp-content/uploads/ && find . -type f \
        $MTIME_FILTER \
        ! -path '*/wc-logs/*' \
        ! -path '*/wp-migrate-db/*' \
        ! -path '*/PDF_EXTENDED_TEMPLATES/tmp/*' \
        ! -path '*/cache/*' \
        ! -path '*/tmp/*' \
        ! -name '*.log' \
        ! -name '*.php' \
        -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2- | sed 's|^\./||'" > "$FILES_LIST" 2>/dev/null

    FILE_COUNT=$(wc -l < "$FILES_LIST")
    if [ -n "$DAYS_BACK" ]; then
        echo -e "${BLUE}  Found ${FILE_COUNT} files to sync from last ${DAYS_BACK} days (sorted newest to oldest)${NC}"
    else
        echo -e "${BLUE}  Found ${FILE_COUNT} files to sync (sorted newest to oldest)${NC}"
    fi
    echo -e ""

    # rsync command with sorted file list, progress, compression
    rsync -avz \
        --progress \
        --stats \
        --human-readable \
        --files-from="$FILES_LIST" \
        "$PROD_SSH:$PROD_PATH/wp-content/uploads/" \
        "$LOCAL_UPLOADS_PATH/" 2>&1 | grep -E "sending|receiving|sent|total|speedup|\.jpg|\.jpeg|\.png|\.gif|\.pdf|\.svg|\.webp|\.mp4|\.mov|\.zip" || true

    RSYNC_EXIT_CODE=${PIPESTATUS[0]}

    # Clean up temp file
    rm -f "$FILES_LIST"

    SYNC_END=$(date +%s)
    SYNC_TIME=$((SYNC_END - SYNC_START))

    echo -e ""

    # Check if rsync completed successfully
    if [ $RSYNC_EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}  rsync completed successfully ✓${NC}"
    elif [ $RSYNC_EXIT_CODE -eq 23 ]; then
        echo -e "${YELLOW}  Warning: rsync completed with partial transfer (exit code 23)${NC}"
        echo -e "${YELLOW}  Some files could not be transferred, but sync continued${NC}"
    elif [ $RSYNC_EXIT_CODE -eq 24 ]; then
        echo -e "${YELLOW}  Warning: rsync completed with partial transfer (exit code 24)${NC}"
        echo -e "${YELLOW}  Some source files vanished during transfer (normal for active sites)${NC}"
    else
        echo -e "${RED}Error: rsync failed with exit code $RSYNC_EXIT_CODE${NC}"
        exit 1
    fi

    # Get final size of local uploads directory
    UPLOADS_SIZE_AFTER=$(du -sh "$LOCAL_UPLOADS_PATH" 2>/dev/null | awk '{print $1}')
    echo -e "${BLUE}  Local uploads size after sync: ${UPLOADS_SIZE_AFTER}${NC}"

    # Set correct permissions for web server access
    echo -e "${BLUE}  Setting correct file permissions...${NC}"
    find "$LOCAL_UPLOADS_PATH" -type d -exec chmod 755 {} \; 2>/dev/null || true
    find "$LOCAL_UPLOADS_PATH" -type f -exec chmod 644 {} \; 2>/dev/null || true
    echo -e "${GREEN}  Permissions updated ✓${NC}"
    echo -e ""

    echo -e "${BLUE}  Time taken: ${SYNC_TIME}s${NC}"
    echo -e "${GREEN}  Media synced successfully ✓${NC}"
    echo -e ""
fi

# Fix URLs to point to local if requested
if [ "$FIX_URLS" = true ]; then
    # Setup WP-CLI if not already set up (for standalone --fix-urls mode)
    if [ -z "$WP_CLI" ]; then
        echo -e "${GREEN}Setting up WP-CLI for URL fixing...${NC}"

        # Check WordPress container
        if ! $DOCKER_COMPOSE ps | grep -q "$WORDPRESS_CONTAINER"; then
            echo -e "${RED}Error: WordPress container is not running${NC}"
            echo "Start your containers with: docker-compose up -d"
            exit 1
        fi

        WP_CLI_PATH="/tmp/wp-cli.phar"
        WP_CLI="php $WP_CLI_PATH --allow-root"

        if ! $DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER test -f "$WP_CLI_PATH" 2>/dev/null; then
            echo -e "${BLUE}  WP-CLI not found in container, downloading...${NC}"
            $DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER sh -c "curl -o $WP_CLI_PATH https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x $WP_CLI_PATH"
            echo -e "${GREEN}  WP-CLI downloaded successfully ✓${NC}"
        fi
        echo -e ""
    fi

    echo -e "${GREEN}Fixing URLs to point to local development...${NC}"
    echo -e "${BLUE}  This will replace all production URLs with local URLs${NC}"
    echo -e ""

    # Replace main production URL with local URL
    echo -e "${BLUE}  Replacing: $PROD_URL -> $LOCAL_URL${NC}"
    REPLACE_OUTPUT=$($DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER $WP_CLI search-replace "$PROD_URL" "$LOCAL_URL" --path="$CONTAINER_WP_PATH" --all-tables 2>&1)
    echo -e "${BLUE}${REPLACE_OUTPUT}${NC}"
    echo -e ""

    # Handle HTTP variant if production is HTTPS
    if [[ $PROD_URL == https://* ]]; then
        PROD_URL_HTTP="${PROD_URL/https:/http:}"
        LOCAL_URL_HTTP="${LOCAL_URL/https:/http:}"
        echo -e "${BLUE}  Also checking HTTP variant: $PROD_URL_HTTP -> $LOCAL_URL_HTTP${NC}"
        REPLACE_HTTP_OUTPUT=$($DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER $WP_CLI search-replace "$PROD_URL_HTTP" "$LOCAL_URL_HTTP" --path="$CONTAINER_WP_PATH" --all-tables 2>&1)
        echo -e "${BLUE}${REPLACE_HTTP_OUTPUT}${NC}"
        echo -e ""
    fi

    # Fix upload URLs specifically
    PROD_UPLOADS_URL="$PROD_URL/wp-content/uploads"
    LOCAL_UPLOADS_URL="$LOCAL_URL/wp-content/uploads"
    echo -e "${BLUE}  Fixing upload URLs: $PROD_UPLOADS_URL -> $LOCAL_UPLOADS_URL${NC}"
    UPLOADS_OUTPUT=$($DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER $WP_CLI search-replace "$PROD_UPLOADS_URL" "$LOCAL_UPLOADS_URL" --path="$CONTAINER_WP_PATH" --all-tables 2>&1)
    echo -e "${BLUE}${UPLOADS_OUTPUT}${NC}"
    echo -e ""

    # Replace old localhost:8080 URLs with new local URL
    OLD_LOCAL_URL="http://localhost:8080"
    echo -e "${BLUE}  Replacing old local URL: $OLD_LOCAL_URL -> $LOCAL_URL${NC}"
    OLD_LOCAL_OUTPUT=$($DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER $WP_CLI search-replace "$OLD_LOCAL_URL" "$LOCAL_URL" --path="$CONTAINER_WP_PATH" --all-tables 2>&1)
    echo -e "${BLUE}${OLD_LOCAL_OUTPUT}${NC}"
    echo -e ""

    echo -e "${GREEN}  URLs fixed successfully ✓${NC}"
    echo -e ""
fi

# Flush cache (skip in config-only mode, run in all other modes)
if [ "$CONFIG_ONLY" = false ]; then
    echo -e "${GREEN}[8/8] Flushing WordPress cache...${NC}"
fi
if [ "$CONFIG_ONLY" = false ]; then
    $DOCKER_COMPOSE exec -T $WORDPRESS_CONTAINER $WP_CLI cache flush --path="$CONTAINER_WP_PATH" 2>/dev/null || true
    echo -e "${GREEN}  Cache flushed ✓${NC}"
    echo -e ""
fi

# Clean up (only run if we pulled database)
if [ "$DB_PULL" = true ] || [ "$FULL" = true ]; then
echo -e "${GREEN}Cleaning up temporary files...${NC}"
echo -e "${BLUE}  Removing: $SQL_DIR/amr.sql${NC}"
rm "$SQL_DIR/amr.sql"
echo -e "${GREEN}  Cleanup complete ✓${NC}"
echo -e ""
fi

# Calculate total time
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))
MINUTES=$((TOTAL_TIME / 60))
SECONDS=$((TOTAL_TIME % 60))

echo -e "${YELLOW}======================================${NC}"
if [ "$FULL" = true ]; then
    echo -e "${GREEN}Full Sync Complete (DB + Plugins + Themes + Media + URLs)!${NC}"
elif [ "$DB_PULL" = true ]; then
    echo -e "${GREEN}Database Pull Complete!${NC}"
elif [ "$PULL_UPLOADS" = true ]; then
    echo -e "${GREEN}Uploads Sync Complete!${NC}"
elif [ "$FIX_URLS" = true ]; then
    echo -e "${GREEN}URL Fix Complete!${NC}"
elif [ "$PULL_PLUGINS" = true ]; then
    echo -e "${GREEN}Plugin Sync Complete!${NC}"
elif [ "$PULL_THEMES" = true ]; then
    echo -e "${GREEN}Theme Sync Complete!${NC}"
elif [ "$CONFIG_ONLY" = true ]; then
    echo -e "${GREEN}Config Sync Complete!${NC}"
fi
echo -e "${YELLOW}======================================${NC}"
echo -e "${CYAN}Summary:${NC}"
if [ "$FULL" = true ]; then
    echo -e "${BLUE}  Production SSH: ${PROD_SSH}${NC}"
    echo -e "${BLUE}  Production URL: ${PROD_URL}${NC}"
    echo -e "${BLUE}  Local URL: ${LOCAL_URL}${NC}"
    echo -e "${BLUE}  Local backup: $SQL_DIR/backup-local-${TIMESTAMP}.sql${NC}"
    echo -e "${BLUE}  Backup size: ${BACKUP_SIZE}${NC}"
    echo -e "${BLUE}  Database size: ${EXPORT_SIZE}${NC}"
    echo -e "${GREEN}  Database imported ✓${NC}"
    echo -e "${GREEN}  Plugins synced ✓${NC}"
    echo -e "${GREEN}  Themes synced ✓${NC}"
    echo -e "${GREEN}  Media synced ✓${NC}"
    echo -e "${GREEN}  URLs fixed to local ✓${NC}"
    echo -e "${GREEN}  Security keys synced: ${KEYS_SYNCED}/8${NC}"
elif [ "$PULL_UPLOADS" = true ] && [ "$FULL" = false ]; then
    echo -e "${BLUE}  Production SSH: ${PROD_SSH}${NC}"
    echo -e "${BLUE}  Production Path: ${PROD_PATH}/wp-content/uploads/${NC}"
    echo -e "${BLUE}  Local Path: $LOCAL_UPLOADS_PATH${NC}"
    echo -e "${BLUE}  Size before: ${UPLOADS_SIZE_BEFORE}${NC}"
    echo -e "${BLUE}  Size after: ${UPLOADS_SIZE_AFTER}${NC}"
    echo -e "${GREEN}  Media synced from production ✓${NC}"
    echo -e "${YELLOW}  Excluded: logs, cache, tmp, PHP files${NC}"
elif [ "$FIX_URLS" = true ] && [ "$FULL" = false ]; then
    echo -e "${BLUE}  Production URL: ${PROD_URL}${NC}"
    echo -e "${BLUE}  Local URL: ${LOCAL_URL}${NC}"
    echo -e "${GREEN}  All URLs fixed to point to local ✓${NC}"
elif [ "$PULL_PLUGINS" = true ]; then
    echo -e "${BLUE}  Production SSH: ${PROD_SSH}${NC}"
    echo -e "${BLUE}  Production Path: ${PROD_PATH}${NC}"
    echo -e "${GREEN}  Plugins synced from production ✓${NC}"
elif [ "$PULL_THEMES" = true ]; then
    echo -e "${BLUE}  Production SSH: ${PROD_SSH}${NC}"
    echo -e "${BLUE}  Production Path: ${PROD_PATH}${NC}"
    echo -e "${GREEN}  Themes synced from production ✓${NC}"
elif [ "$DB_PULL" = true ]; then
    if [ -n "$LOCAL_FILE" ]; then
        echo -e "${BLUE}  Source: Local file ($LOCAL_FILE)${NC}"
    else
        echo -e "${BLUE}  Source: Production export${NC}"
    fi
    echo -e "${BLUE}  Production URL: ${PROD_URL}${NC}"
    echo -e "${BLUE}  Local URL: ${LOCAL_URL}${NC}"
    echo -e "${BLUE}  Local backup: $SQL_DIR/backup-local-${TIMESTAMP}.sql${NC}"
    echo -e "${BLUE}  Backup size: ${BACKUP_SIZE}${NC}"
    echo -e "${BLUE}  Database size: ${EXPORT_SIZE}${NC}"
    echo -e "${GREEN}  Media files continue to load from production${NC}"
    echo -e "${GREEN}  Security keys synced: ${KEYS_SYNCED}/8${NC}"
fi
echo -e "${BLUE}  Total time: ${MINUTES}m ${SECONDS}s${NC}"
echo -e "${YELLOW}======================================${NC}"

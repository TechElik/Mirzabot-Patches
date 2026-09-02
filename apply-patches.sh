#!/bin/bash
# mirzabot-patches manager
# Usage: sudo bash apply-patches.sh

BOT_DIR="/var/www/html/mirzaprobotconfig"
FPM_POOL="/etc/php/8.2/fpm/pool.d/www.conf"
FPM_SERVICE="php8.2-fpm"
PATCH_REPO="https://raw.githubusercontent.com/techelik/mirzabot-patches/main"
BACKUP_ROOT="/var/www/html"

C_OK='\033[32m'
C_BAD='\033[31m'
C_WARN='\033[33m'
C_KEY='\033[36m'
C_DIM='\033[2m'
C_TITLE='\033[1;35m'
CR='\033[0m'

FILES=(
    "admin.php" "function.php" "index.php" "table.php" "keyboard.php"
    "lang/fa.php"
    "api/miniapp.php" "api/users.php"
    "cronbot/gift.php" "cronbot/lottery.php" "cronbot/payment_expire.php" "cronbot/plisio.php" "cronbot/uptime_panel.php"
    "vpnbot/Default/admin.php" "vpnbot/Default/index.php"
    "vpnbot/update/admin.php" "vpnbot/update/index.php"
)

function banner() {
    clear
    echo -e "${C_TITLE}╔════════════════════════════════════════════╗${CR}"
    echo -e "${C_TITLE}║           Mirzabot Patches Manager           ║${CR}"
    echo -e "${C_TITLE}╚════════════════════════════════════════════╝${CR}"
    echo ""
}

function pause() {
    echo ""
    read -rp "  Press Enter to return to the menu... " _
}

function require_bot_installed() {
    if [ ! -f "$BOT_DIR/config.php" ]; then
        echo -e "  ${C_BAD}●${CR} mirzabot was not found in $BOT_DIR. Run the standard installer first."
        pause
        return 1
    fi
    return 0
}

function install_fresh_patched() {
    banner
    echo -e "${C_KEY}▶ Install pre-patched version from scratch${CR}\n"
    echo -e "  ${C_DIM}For users who do NOT have mirzabot installed yet and want a fresh install${CR}"
    echo -e "  ${C_DIM}that already includes all stability fixes and the premium emoji system.${CR}\n"

    if [ -f "$BOT_DIR/config.php" ]; then
        echo -e "  ${C_WARN}Warning:${CR} mirzabot already appears to be installed in $BOT_DIR."
        echo -e "  This option runs a fresh installer meant for a clean server."
    fi
    read -rp "  Continue with a fresh install? (type yes to confirm) " confirm
    if [ "$confirm" != "yes" ]; then
        echo "  Cancelled."
        pause
        main_menu
        return
    fi

    echo -e "\n  ${C_DIM}Downloading and running our pre-patched installer...${CR}\n"
    curl -o /tmp/mirza-install.sh -L "https://raw.githubusercontent.com/techelik/mirzabot-patches/main/install.sh" \
        && bash /tmp/mirza-install.sh

    pause
    main_menu
}

function update_to_baseline() {
    banner
    echo -e "${C_KEY}▶ Update existing installation to base version 0.3.1${CR}\n"
    echo -e "  ${C_DIM}For users who have an OLDER version of the original mirzabot installed${CR}"
    echo -e "  ${C_DIM}and need to bring it up to version 0.3.1 first, before applying our patches${CR}"
    echo -e "  ${C_DIM}(option 3 in this menu). This step alone does NOT apply our patches.${CR}\n"

    read -rp "  Continue updating to 0.3.1? (type yes to confirm) " confirm
    if [ "$confirm" != "yes" ]; then
        echo "  Cancelled."
        pause
        main_menu
        return
    fi

    echo -e "\n  ${C_DIM}Downloading the official installer and updating to 0.3.1...${CR}\n"
    curl -o install.sh -L "https://raw.githubusercontent.com/mahdiMGF2/mirzabot/main/install.sh"
    chmod +x install.sh
    bash install.sh update --version 0.3.1

    echo -e "\n  ${C_OK}●${CR} If the update finished successfully, run option 3 (Apply custom patches) next."
    pause
    main_menu
}

function apply_patches() {
    banner
    echo -e "${C_KEY}▶ Apply patches${CR}\n"
    require_bot_installed || { main_menu; return; }

    # ── ۱. بکاپ از دیتابیس ──────────────────────────────────
    echo -e "  ${C_DIM}[1/6]${CR} Backing up database..."
    local dbhost=$(grep '^\$dbhost' "$BOT_DIR/config.php" | cut -d"'" -f2)
    local dbname=$(grep '^\$dbname' "$BOT_DIR/config.php" | cut -d"'" -f2)
    local dbuser=$(grep '^\$usernamedb' "$BOT_DIR/config.php" | cut -d"'" -f2)
    local dbpass=$(grep '^\$passworddb' "$BOT_DIR/config.php" | cut -d"'" -f2)
    [ -z "$dbhost" ] && dbhost="localhost"

    if [ -n "$dbname" ] && [ -n "$dbuser" ] && [ -n "$dbpass" ]; then
        local db_backup="/root/mirza-backup-$(date +%Y-%m-%d-%H-%M-%S).sql"
        if mysqldump -h "$dbhost" -u "$dbuser" -p"$dbpass" --no-tablespaces --ssl-mode=DISABLED "$dbname" > "$db_backup" 2>/dev/null; then
            echo -e "        ${C_OK}✓${CR} Database backup saved to: ${C_DIM}${db_backup}${CR}"
            
            local bot_token=$(grep '^\$APIKEY' "$BOT_DIR/config.php" | cut -d"'" -f2)
            local admin_id=$(grep '^\$adminnumber' "$BOT_DIR/config.php" | cut -d"'" -f2)
            if [ -n "$bot_token" ] && [ -n "$admin_id" ]; then
                curl -s -X POST "https://api.telegram.org/bot$bot_token/sendDocument" \
                    -F "chat_id=$admin_id" \
                    -F "document=@$db_backup" \
                    -F "caption=📦 Database Backup before applying patches" > /dev/null
                echo -e "        ${C_OK}✓${CR} Database backup sent to Telegram"
            fi
        else
            echo -e "        ${C_WARN}!${CR} Database backup failed (check credentials). Continuing with folder backup."
        fi
    else
        echo -e "        ${C_WARN}!${CR} Could not read database credentials. Skipping database backup."
    fi

    # ── ۲. بکاپ از پوشه ──────────────────────────────────────
    local backup_dir="${BACKUP_ROOT}/mirzaprobotconfig-backup-$(date +%F-%H%M)"
    echo -e "  ${C_DIM}[2/6]${CR} Backing up the current bot folder..."
    cp -r "$BOT_DIR" "$backup_dir"
    echo -e "        ${C_OK}✓${CR} Folder backup saved to: ${C_DIM}${backup_dir}${CR}"

    # ── ۳. دانلود و اعمال وصله‌ها ──────────────────────────
    echo -e "  ${C_DIM}[3/6]${CR} Downloading and applying patched files..."
    local fail=0
    for f in "${FILES[@]}"; do
        mkdir -p "$BOT_DIR/$(dirname "$f")"
        if curl -fsSL "$PATCH_REPO/$f" -o "$BOT_DIR/$f"; then
            echo -e "        ${C_OK}✓${CR} $f"
        else
            echo -e "        ${C_BAD}✗${CR} $f ${C_BAD}(download failed)${CR}"
            fail=1
        fi
    done
    if [ "$fail" -eq 1 ]; then
        echo -e "\n  ${C_BAD}●${CR} Some files failed to download. Use the Restore option to roll back."
        pause
        main_menu
        return
    fi

    # ── ۴. اجرای migration دیتابیس ──────────────────────────
    echo -e "  ${C_DIM}[4/6]${CR} Running database migration..."
    (cd "$BOT_DIR" && php8.2 table.php) && echo -e "        ${C_OK}✓${CR} table.php executed" || echo -e "        ${C_WARN}!${CR} table.php reported a warning"

    # ── ۵. تنظیمات PHP-FPM ──────────────────────────────────
    echo -e "  ${C_DIM}[5/6]${CR} Tuning PHP-FPM for stability..."
    if [ -f "$FPM_POOL" ]; then
        grep -q "^request_terminate_timeout" "$FPM_POOL" \
            && sed -i 's/^request_terminate_timeout.*/request_terminate_timeout = 30s/' "$FPM_POOL" \
            || echo "request_terminate_timeout = 30s" >> "$FPM_POOL"
        sed -i 's/^pm.max_children = .*/pm.max_children = 12/' "$FPM_POOL"
        systemctl restart "$FPM_SERVICE"
        echo -e "        ${C_OK}✓${CR} PHP-FPM configured and restarted"
    else
        echo -e "        ${C_WARN}!${CR} Pool file not found, step skipped"
    fi

    # ── ۶. تنظیم مالکیت فایل‌ها ─────────────────────────────
    echo -e "  ${C_DIM}[6/6]${CR} Restoring file ownership..."
    chown -R www-data:www-data "$BOT_DIR"
    echo -e "        ${C_OK}✓${CR} Done"

    echo -e "\n  ${C_OK}●${CR} ${C_OK}Patches applied successfully.${CR}"
    echo -e "  ${C_DIM}Premium emoji icons can now be set directly inside the bot's admin panel.${CR}"
    pause
    main_menu
}

function list_backups() {
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "mirzaprobotconfig-backup-*" 2>/dev/null | sort -r
}

function restore_backup() {
    banner
    echo -e "${C_KEY}▶ Restore a backup${CR}\n"

    local backups=()
    while IFS= read -r d; do backups+=("$d"); done < <(list_backups)

    if [ "${#backups[@]}" -eq 0 ]; then
        echo -e "  ${C_WARN}!${CR} No backups found."
        pause
        main_menu
        return
    fi

    echo -e "  ${C_DIM}Available backups:${CR}\n"
    local i=1
    for b in "${backups[@]}"; do
        local sz
        sz=$(du -sh "$b" 2>/dev/null | awk '{print $1}')
        echo -e "    ${C_KEY}[$i]${CR}  $(basename "$b")  ${C_DIM}(${sz})${CR}"
        i=$((i + 1))
    done
    echo -e "\n    ${C_KEY}[0]${CR}  Cancel\n"

    read -rp "  ❯ Which backup do you want to restore? [0-$((i - 1))] " choice
    if [ "$choice" = "0" ] || [ -z "$choice" ]; then
        main_menu
        return
    fi
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#backups[@]}" ]; then
        echo -e "  ${C_BAD}●${CR} Invalid choice."
        pause
        main_menu
        return
    fi

    local selected="${backups[$((choice - 1))]}"
    echo ""
    echo -e "  ${C_WARN}Warning:${CR} the current mirzabot folder will be replaced with this backup."
    read -rp "  Are you sure? (type yes to confirm) " confirm
    if [ "$confirm" != "yes" ]; then
        echo "  Cancelled."
        pause
        main_menu
        return
    fi

    echo -e "\n  ${C_DIM}[1/3]${CR} Setting the current version aside..."
    if [ -d "$BOT_DIR" ]; then
        mv "$BOT_DIR" "${BOT_DIR}_replaced_$(date +%F-%H%M)"
    fi

    echo -e "  ${C_DIM}[2/3]${CR} Restoring from backup..."
    cp -r "$selected" "$BOT_DIR"
    chown -R www-data:www-data "$BOT_DIR"

    echo -e "  ${C_DIM}[3/3]${CR} Restarting services..."
    systemctl restart "$FPM_SERVICE" 2>/dev/null
    systemctl restart apache2 2>/dev/null

    echo -e "\n  ${C_OK}●${CR} ${C_OK}Restore complete.${CR} Send a test message to the bot."
    pause
    main_menu
}

function delete_old_backups() {
    banner
    echo -e "${C_KEY}▶ Delete old backups${CR}\n"
    local backups=()
    while IFS= read -r d; do backups+=("$d"); done < <(list_backups)

    if [ "${#backups[@]}" -eq 0 ]; then
        echo -e "  ${C_WARN}!${CR} No backups found."
        pause
        main_menu
        return
    fi

    local i=1
    for b in "${backups[@]}"; do
        local sz
        sz=$(du -sh "$b" 2>/dev/null | awk '{print $1}')
        echo -e "    ${C_KEY}[$i]${CR}  $(basename "$b")  ${C_DIM}(${sz})${CR}"
        i=$((i + 1))
    done
    echo -e "\n    ${C_KEY}[0]${CR}  Cancel\n"
    read -rp "  ❯ Which backup should be deleted? [0-$((i - 1))] " choice
    if [ "$choice" = "0" ] || [ -z "$choice" ]; then main_menu; return; fi
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#backups[@]}" ]; then
        echo -e "  ${C_BAD}●${CR} Invalid choice."
        pause
        main_menu
        return
    fi
    rm -rf "${backups[$((choice - 1))]}"
    echo -e "  ${C_OK}✓${CR} Deleted."
    pause
    main_menu
}

function main_menu() {
    banner
    echo -e "  ${C_KEY}[1]${CR}  Install pre-patched version from scratch ${C_DIM}(no bot installed yet)${CR}"
    echo -e "  ${C_KEY}[2]${CR}  Update existing install to base version 0.3.1 ${C_DIM}(older version installed)${CR}"
    echo -e "  ${C_KEY}[3]${CR}  Apply custom patches ${C_DIM}(0.3.1 already installed, auto-backup included)${CR}"
    echo -e "  ${C_KEY}[4]${CR}  Restore a backup"
    echo -e "  ${C_KEY}[5]${CR}  Delete old backups"
    echo -e "  ${C_KEY}[0]${CR}  Exit"
    echo ""
    read -rp "  ❯ Your choice: " choice
    case "$choice" in
        1) install_fresh_patched ;;
        2) update_to_baseline ;;
        3) apply_patches ;;
        4) restore_backup ;;
        5) delete_old_backups ;;
        0) echo ""; exit 0 ;;
        *) main_menu ;;
    esac
}

main_menu
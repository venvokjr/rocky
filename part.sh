#!/bin/bash

menu_install_logic() {
    echo "Downloading management menu..."
    dnf install tar gzip -y >/dev/null 2>&1

    local tmpdir
    tmpdir=$(mktemp -d)
    wget -qO "$tmpdir/repo.tar.gz" "$REPO_TARBALL"
    tar -xzf "$tmpdir/repo.tar.gz" -C "$tmpdir" >/dev/null 2>&1

    local srcdir="$tmpdir/${REPO_NAME}-${REPO_BRANCH}"

    # Install shared libraries into /usr/local/sbin/lib (sourced, not commands).
    mkdir -p /usr/local/sbin/lib
    if [[ -d "$srcdir/scripts/lib" ]]; then
        install -m 0644 "$srcdir/scripts/lib/"*.sh /usr/local/sbin/lib/ 2>/dev/null
    fi

    # Install command scripts (strip .sh) into /usr/local/sbin so they are
    # callable by bare name. Exclude api/ and lib/.
    mkdir -p /usr/local/sbin/api
    find "$srcdir/scripts" -maxdepth 2 -type f -name '*.sh' \
         ! -path '*/api/*' ! -path '*/lib/*' | while read -r file; do
        name=$(basename "$file" .sh)
        install -m 0755 "$file" "/usr/local/sbin/$name"
    done

    # Install API command scripts (strip .sh) into /usr/local/sbin/api
    find "$srcdir/scripts/api" -maxdepth 1 -type f -name '*.sh' | while read -r file; do
        name=$(basename "$file" .sh)
        install -m 0755 "$file" "/usr/local/sbin/api/$name"
    done

    # Install the uninstaller as a callable command.
    [[ -f "$srcdir/uninstall.sh" ]] && install -m 0755 "$srcdir/uninstall.sh" /usr/local/sbin/uninstall

    rm -rf "$tmpdir"
    echo "Menu scripts and libraries integrated."
}

if [[ -f "/usr/local/sbin/menu" ]]; then
    echo "Menu scripts already exist."
    echo -e "1) Skip\n2) Update Menu"
    read -p "Select [1-2]: " menu_choice
    [[ "$menu_choice" == "2" ]] && menu_install_logic
else
    menu_install_logic
fi

# Initialize SQLite database (single source of truth) and migrate any legacy data.
echo "Initializing account database (SQLite)..."
if [[ -f /usr/local/sbin/lib/db.sh ]]; then
    . /usr/local/sbin/lib/db.sh
    db_init
    # Import legacy .txt accounts if present (idempotent).
    if [[ -d /etc/xray/database ]] && [[ -x /usr/local/sbin/db-migrate ]]; then
        /usr/local/sbin/db-migrate >/dev/null 2>&1 || true
    fi
    echoess "Database initialized at /etc/xray/xray.db."
else
    echo "Database library missing; menu may not function."
fi
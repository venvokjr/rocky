#!/usr/bin/env bash
# ========================================================
# Project: Autoscript VPN by Codenerg
# Description: View SSH account details
# License: Commercial Source Code License (see LICENSE file)
# Repository: https://github.com/codenerg/autoscript
# ========================================================
. /usr/local/sbin/lib/account.sh

db_init

clear
ui_header "SSH ACCOUNT DETAILS"
db_query "SELECT username, datetime(expired_at,'unixepoch','localtime')
          FROM accounts WHERE protocol='ssh' AND status!='deleted'
          ORDER BY username;" \
  | while IFS='|' read -r u e; do printf " %-20s %s\n" "$u" "$e"; done
ui_rule

read -rp "Enter username: " user
if ! valid_username "$user" || ! db_account_exists "ssh" "$user"; then
  err "User not found."; read -n1 -s -r -p "Press any key..."; menu; exit 1
fi

pass=$(db_get_field "ssh" "$user" "secret")
ipl=$(db_get_field "ssh" "$user" "limit_ip"); [[ "$ipl" == "0" ]] && ipl="Unlimited"
exp=$(db_query "SELECT datetime(expired_at,'unixepoch','localtime') FROM accounts WHERE protocol='ssh' AND username='$(sql_escape "$user")' AND status!='deleted';")

clear
ssh_print_cli "$user" "$pass" "$ipl" "$exp" "SSH ACCOUNT DETAILS"
read -n 1 -s -r -p " Press any key to back to menu..."
menu

#!/usr/bin/env bash
# ========================================================
# Project: Autoscript VPN by Codenerg
# Description: Check active VMESS logins + quota usage
# License: Commercial Source Code License (see LICENSE file)
# Repository: https://github.com/codenerg/autoscript
# ========================================================
. /usr/local/sbin/lib/account.sh

db_init
xray_cek_monitor vmess
ui_back
menu

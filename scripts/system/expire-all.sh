#!/usr/bin/env bash
# ========================================================
# Project: Autoscript VPN by Codenerg
# Description: Run every protocol's auto-expire pass in one shot.
#              Invoked by the autoexpire.timer systemd unit (no cron).
# License: Commercial Source Code License (see LICENSE file)
# Repository: https://github.com/codenerg/autoscript
# ========================================================
# Each xp-* command is DB-driven and idempotent (safe to run every minute).
xp-ssh
xp-vless
xp-vmess
xp-trojan
exit 0

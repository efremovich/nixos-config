#!/usr/bin/env python3

import subprocess

# Иконки и цвета в стиле ssh_tunnel_status.py (octicon-щиты из CaskaydiaCove NF).
ACTIVE_ICON = ""  # oct-shield_lock
INACTIVE_ICON = ""  # oct-shield_slash


active = (
    subprocess.run(
        ["systemctl", "is-active", "--quiet", "wg-quick-wg0.service"],
        check=False,
    ).returncode
    == 0
)

if active:
    print(f"<span foreground='#40a02b'>{ACTIVE_ICON} </span>")
else:
    print(f"<span foreground='#d20f39'>{INACTIVE_ICON} </span>")

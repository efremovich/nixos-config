#!/usr/bin/env python3

import subprocess


def get_status():
    proc = subprocess.run(
        ["openvpn3", "sessions-list"],
        capture_output=True,
        text=True,
    )
    return "active" if "Client connected" in proc.stdout else "inactive"


status = get_status()
if status == "active":
    print("<span foreground='#40a02b'>󰦝</span>")
else:
    print("<span foreground='#d20f39'>󰦜</span>")
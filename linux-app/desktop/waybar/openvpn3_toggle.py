#!/usr/bin/env python3

import subprocess


def is_connected():
    proc = subprocess.run(
        ["openvpn3", "sessions-list"],
        capture_output=True,
        text=True,
    )
    return "Client connected" in proc.stdout


def toggle():
    if is_connected():
        subprocess.run(["systemctl", "stop", "openvpn3-watch.timer"])
        subprocess.run(["systemctl", "start", "openvpn3-watch-stop.service"])
    else:
        subprocess.run(["systemctl", "start", "openvpn3-watch.timer"])
        subprocess.run(["systemctl", "start", "openvpn3-watch.service"])


toggle()
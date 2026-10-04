#!/usr/bin/env python3

import subprocess


active = subprocess.run(
    ["systemctl", "is-active", "--quiet", "wg-quick-wg0.service"],
    check=False,
).returncode == 0
subprocess.run(
    ["systemctl", "stop" if active else "start", "wg-quick-wg0.service"],
    check=True,
)

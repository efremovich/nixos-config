#!/usr/bin/env python3

import subprocess


status = subprocess.run(
    ["systemctl", "is-active", "--quiet", "wg-quick-wg0.service"],
    check=False,
).returncode
print("󰌾" if status == 0 else "󰿆")

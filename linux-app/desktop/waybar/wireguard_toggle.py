#!/usr/bin/env python3
"""Включение/выключение туннеля wg0 по клику в waybar."""

import subprocess

UNIT = "wg-quick-wg0.service"


def systemctl(*args: str) -> "subprocess.CompletedProcess[str]":
    return subprocess.run(["systemctl", *args], capture_output=True, text=True, check=False)


def notify(body: str, urgency: str = "low") -> None:
    subprocess.run(["notify-send", "-u", urgency, "WireGuard", body], check=False)


if not systemctl("list-unit-files", "--no-legend", UNIT).stdout.strip():
    notify(f"{UNIT} не включён на этом хосте", "critical")
    raise SystemExit(1)

active = systemctl("is-active", "--quiet", UNIT).returncode == 0
verb = "stop" if active else "start"

result = systemctl(verb, UNIT)
if result.returncode != 0:
    lines = (result.stderr + result.stdout).strip().splitlines()
    notify(f"systemctl {verb} не удался: {lines[-1] if lines else result.returncode}", "critical")
    raise SystemExit(result.returncode)

notify("Туннель выключен" if active else "Туннель включён")

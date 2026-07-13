#!/usr/bin/env python3

import json
import os
import subprocess
import sys
from pathlib import Path

SECRETS_FILE = Path.home() / ".config" / "waybar" / "secrets.json"
RUN_SECRETS = Path("/run/secrets")


def read_secret(name: str) -> str | None:
    secret_path = RUN_SECRETS / name
    if secret_path.exists():
        return secret_path.read_text(encoding="utf-8").strip()
    return None


def load_ssh_config():
    defaults = {
        "host": "127.0.0.1",
        "user": "user",
        "port": 22,
        "proxy_port": 1050,
        "key_file": str(Path.home() / ".ssh" / "id_rsa"),
    }

    if SECRETS_FILE.exists():
        with open(SECRETS_FILE, encoding="utf-8") as handle:
            data = json.load(handle)
        defaults.update(data)

    for key, secret_name in {
        "host": "waybar_ssh_host",
        "user": "waybar_ssh_user",
        "key_file": "waybar_ssh_key_file",
    }.items():
        value = read_secret(secret_name)
        if value:
            defaults[key] = value

    for key, secret_name in {
        "port": "waybar_ssh_port",
        "proxy_port": "waybar_proxy_port",
    }.items():
        value = read_secret(secret_name)
        if value:
            defaults[key] = int(value)

    return defaults


def is_ssh_tunnel_running(port=1050):
    try:
        result = subprocess.run(
            ["pgrep", "-f", f"ssh.*{port}"],
            capture_output=True,
            text=True,
            check=False,
        )
        return result.returncode == 0
    except Exception:
        return False


def start_ssh_tunnel():
    ssh_config = load_ssh_config()
    cmd = [
        "ssh",
        "-i",
        ssh_config["key_file"],
        "-D",
        str(ssh_config["proxy_port"]),
        "-f",
        "-C",
        "-q",
        "-N",
        f"{ssh_config['user']}@{ssh_config['host']}",
        "-p",
        str(ssh_config["port"]),
    ]

    try:
        subprocess.run(cmd, check=True)
        print("SSH туннель запущен")
    except subprocess.CalledProcessError as exc:
        print(f"Ошибка запуска SSH туннеля: {exc}")


def stop_ssh_tunnel(port=1050):
    try:
        subprocess.run(["pkill", "-f", f"ssh.*{port}"], check=True)
        print("SSH туннель остановлен")
    except subprocess.CalledProcessError as exc:
        print(f"Ошибка остановки SSH туннеля: {exc}")


if __name__ == "__main__":
    proxy_port = load_ssh_config()["proxy_port"]
    if is_ssh_tunnel_running(proxy_port):
        stop_ssh_tunnel(proxy_port)
    else:
        start_ssh_tunnel()

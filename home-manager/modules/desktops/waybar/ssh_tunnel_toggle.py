#!/usr/bin/env python3

import subprocess
import os
import sys

def is_ssh_tunnel_running(port=1050):
    """Проверяет, запущен ли SSH туннель на указанном порту"""
    try:
        result = subprocess.run(['pgrep', '-f', f'ssh.*{port}'], 
                              capture_output=True, text=True)
        return result.returncode == 0
    except Exception as e:
        return False

def start_ssh_tunnel():
    """Запускает SSH туннель"""
    ssh_config = {
        'host': '51.254.148.241', 
        'user': 'fima',
        'port': 22,
        'proxy_port': 1050,
        'key_file': os.path.expanduser('~/.ssh/id_rsa_astral')
    }
    
    cmd = [
        'ssh', '-i', ssh_config['key_file'],
        '-D', str(ssh_config['proxy_port']),
        '-f', '-C', '-q', '-N',
        f"{ssh_config['user']}@{ssh_config['host']}",
        '-p', str(ssh_config['port'])
    ]
    
    try:
        subprocess.run(cmd, check=True)
        print("SSH туннель запущен")
    except subprocess.CalledProcessError as e:
        print(f"Ошибка запуска SSH туннеля: {e}")

def stop_ssh_tunnel(port=1050):
    """Останавливает SSH туннель"""
    try:
        subprocess.run(['pkill', '-f', f'ssh.*{port}'], check=True)
        print("SSH туннель остановлен")
    except subprocess.CalledProcessError as e:
        print(f"Ошибка остановки SSH туннеля: {e}")

if __name__ == "__main__":
    if is_ssh_tunnel_running():
        stop_ssh_tunnel()
    else:
        start_ssh_tunnel()

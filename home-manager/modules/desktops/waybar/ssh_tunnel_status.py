#!/usr/bin/env python3

import subprocess
import os

def is_ssh_tunnel_running(port=1050):
    """Проверяет, запущен ли SSH туннель на указанном порту"""
    try:
        # Проверяем процессы SSH с указанным портом
        result = subprocess.run(['pgrep', '-f', f'ssh.*{port}'], 
                              capture_output=True, text=True)
        return result.returncode == 0
    except Exception as e:
        return False

def get_ssh_tunnel_status():
    """Возвращает статус SSH туннеля"""
    if is_ssh_tunnel_running():
        return "active"
    else:
        return "inactive"

if __name__ == "__main__":
    status = get_ssh_tunnel_status()
    if status == "active":
        print("<span foreground='#40a02b'> </span>")  # Зеленый значок
    else:
        print("<span foreground='#d20f39'> </span>")  # Красный значок

#!/usr/bin/env python3

import os
import subprocess
import time
import urllib.request
import urllib.error
from itertools import cycle

WALLPAPERS_DIR = os.path.expanduser("~/Pictures/wallpapers/")
DEFAULT_WALLPAPER_URL = "https://w.wallhaven.cc/full/l3/wallhaven-l37qoq.jpg"
DEFAULT_WALLPAPER_NAME = "default-wallpaper.jpg"


def download_default_wallpaper():
    """Скачивает обои по умолчанию с помощью urllib"""
    try:
        print(f"Скачиваю обои по умолчанию...")
        
        wallpaper_path = os.path.join(WALLPAPERS_DIR, DEFAULT_WALLPAPER_NAME)
        
        # Скачиваем файл с помощью urllib
        urllib.request.urlretrieve(DEFAULT_WALLPAPER_URL, wallpaper_path)
        
        print(f"Обои успешно скачаны: {wallpaper_path}")
        return True
        
    except urllib.error.URLError as e:
        print(f"Ошибка при скачивании обоев: {e}")
        return False
    except Exception as e:
        print(f"Неожиданная ошибка: {e}")
        return False


def check_wallpapers_dir():
    """Проверяет существование папки с обоями и создает ее при необходимости"""
    if not os.path.exists(WALLPAPERS_DIR):
        print(f"Папка {WALLPAPERS_DIR} не существует. Создаю...")
        try:
            os.makedirs(WALLPAPERS_DIR, exist_ok=True)
            print(f"Папка {WALLPAPERS_DIR} создана успешно.")
            
            # Пытаемся скачать обои по умолчанию
            if download_default_wallpaper():
                print("Обои по умолчанию успешно скачаны.")
            else:
                print("Не удалось скачать обои по умолчанию.")
                print("Пожалуйста, добавьте обои вручную в папку и перезапустите скрипт.")
                return False
                
            return True
        except Exception as e:
            print(f"Ошибка при создании папки: {e}")
            return False
    return True


def get_wallpapers():
    """Динамически получает список обоев из папки"""
    supported_formats = ('.png', '.jpg', '.jpeg', '.bmp', '.gif', '.webp')
    wallpapers = []
    
    try:
        for filename in os.listdir(WALLPAPERS_DIR):
            if filename.lower().endswith(supported_formats):
                full_path = os.path.join(WALLPAPERS_DIR, filename)
                if os.path.isfile(full_path):
                    wallpapers.append(full_path)
        
        # Сортируем для предсказуемого порядка
        wallpapers.sort()
        return wallpapers
    except Exception as e:
        print(f"Ошибка при чтении папки с обоями: {e}")
        return []


def set_wallpaper(wallpaper):
    """Устанавливает обои рабочего стола"""
    try:
        subprocess.run(
            [
                "swww",
                "img",
                wallpaper,
                "--transition-type",
                "grow",
            ],
            check=True
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Ошибка при установке обоев: {e}")
        return False
    except FileNotFoundError:
        print("Ошибка: команда 'swww' не найдена. Убедитесь, что swww установлен.")
        return False


def main():
    # Проверяем существование папки
    if not check_wallpapers_dir():
        return
    
    # Получаем список обоев
    wallpapers = get_wallpapers()
    
    if not wallpapers:
        print(f"В папке {WALLPAPERS_DIR} не найдено подходящих файлов обоев.")
        print("Поддерживаемые форматы: PNG, JPG, JPEG, BMP, GIF, WEBP")
        return
    
    print(f"Найдено обоев: {len(wallpapers)}")
    for i, wallpaper in enumerate(wallpapers, 1):
        print(f"{i}. {os.path.basename(wallpaper)}")
    
    # Создаем цикл для переключения обоев
    wallpaper_cycle = cycle(wallpapers)
    
    print("\nЗапуск цикла смены обоев (интервал: 1 час)")
    print("Для остановки нажмите Ctrl+C\n")
    
    try:
        for wallpaper in wallpaper_cycle:
            print(f"Устанавливаю обои: {os.path.basename(wallpaper)}")
            if set_wallpaper(wallpaper):
                print("Обои успешно установлены\n")
            else:
                print("Не удалось установить обои\n")
            
            time.sleep(3600)  # Ждем 1 час
    except KeyboardInterrupt:
        print("\nСкрипт остановлен пользователем")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3

import json
import os
import subprocess

events_of_interest = ["Workspace focused", "Window opened", "Window closed"]


def get_niri_msg_output(msg):
    output = subprocess.check_output(["niri", "msg", "-j", msg])
    output = json.loads(output)
    return output


def wallpaper_cache_dir():
    for base_name in ("awww", "swww"):
        base = os.path.expanduser(f"~/.cache/{base_name}")
        if not os.path.isdir(base):
            continue
        subdirs = sorted(
            d
            for d in os.listdir(base)
            if os.path.isdir(os.path.join(base, d))
        )
        if subdirs:
            return os.path.join(base, subdirs[-1])
        return base
    return os.path.expanduser("~/.cache/awww")


def get_current_wallpaper(monitor):
    path = os.path.join(wallpaper_cache_dir(), monitor)
    with open(path, "rb") as f:
        data = f.read()
    # awww: namespace\0resize\0filter\0img_path (repeated)
    parts = [p.decode(errors="replace") for p in data.split(b"\0") if p]
    if len(parts) >= 4:
        return parts[-1]
    # legacy swww line-based cache
    lines = data.decode(errors="replace").splitlines()
    return lines[-1].strip() if lines else ""


def set_wallpaper(monitor, wallpaper):
    subprocess.run(
        [
            "awww",
            "img",
            "--transition-type",
            "grow",
            "-o",
            monitor,
            wallpaper,
        ]
    )


def change_wallpaper_on_event():
    workspaces = get_niri_msg_output("workspaces")
    active_workspaces = [
        workspace for workspace in workspaces if workspace["is_active"]
    ]
    for active_workspace in active_workspaces:
        active_workspace_is_empty = active_workspace["active_window_id"] is None
        active_workspace_monitor = active_workspace["output"]
        current_wallpaper = get_current_wallpaper(active_workspace_monitor)
        unblurred_wallpaper = current_wallpaper.replace("-blurred", "")
        blurred_wallpaper = unblurred_wallpaper.removesuffix(".png") + "-blurred.png"
        if active_workspace_is_empty:
            wallpaper = unblurred_wallpaper
        else:
            wallpaper = blurred_wallpaper
            if not os.path.exists(wallpaper):
                wallpaper = unblurred_wallpaper
        if current_wallpaper != wallpaper:
            print(f"Setting wallpaper to {wallpaper}")
            set_wallpaper(active_workspace_monitor, wallpaper)


def main():
    event_stream = subprocess.Popen(
        ["niri", "msg", "event-stream"], stdout=subprocess.PIPE
    )
    for line in iter(event_stream.stdout.readline, ""):
        if any(event in line.decode() for event in events_of_interest):
            change_wallpaper_on_event()


if __name__ == "__main__":
    main()

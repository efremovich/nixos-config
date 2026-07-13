#!/usr/bin/env zsh

if [ -s /run/secrets/anthropic_api_key ]; then
  export ANTHROPIC_API_KEY=$(cat /run/secrets/anthropic_api_key)
elif [ -f "$HOME/.secrets/anthropic_api_key.txt" ]; then
  export ANTHROPIC_API_KEY=$(cat "$HOME/.secrets/anthropic_api_key.txt")
fi

export PATH="$PATH:$HOME/.local/bin:/var/lib/flatpak/exports/bin:$HOME/.nix-profile/bin"

walker

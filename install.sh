#!/usr/bin/env bash
# Install the macOS/Linux WezTerm config.
#
# Symlinks wezterm.lua -> ~/.wezterm.lua so edits in this repo stay live.
# Any existing config is backed up first. Safe to re-run.

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$repo_dir/wezterm.lua"
dest="$HOME/.wezterm.lua"

if [ ! -f "$src" ]; then
	echo "error: $src not found" >&2
	exit 1
fi

# Already pointing at our config? Nothing to do.
if [ "$(readlink "$dest" 2>/dev/null || true)" = "$src" ]; then
	echo "Already linked: $dest -> $src"
	exit 0
fi

# Back up an existing file/symlink so nothing is lost.
if [ -e "$dest" ] || [ -L "$dest" ]; then
	backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
	mv "$dest" "$backup"
	echo "Backed up existing config to $backup"
fi

ln -s "$src" "$dest"
echo "Linked $dest -> $src"
echo "Reload WezTerm (Leader+r) or open a new window to apply."

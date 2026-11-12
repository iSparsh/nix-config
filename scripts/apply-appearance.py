#!/usr/bin/env python3
"""Merge only the managed appearance keys into writable application settings."""
import argparse
import json
import os
from pathlib import Path
import shutil
import tempfile

import json5


def merge(current, managed):
    result = dict(current)
    for key, value in managed.items():
        if isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = merge(result[key], value)
        else:
            result[key] = value
    return result


def update_json(path, managed):
    current = json5.loads(path.read_text()) if path.exists() else {}
    if not isinstance(current, dict):
        raise ValueError(f"Expected a settings object: {path}")
    updated = merge(current, managed)
    if updated == current:
        return
    if path.is_symlink():
        raise ValueError(f"Settings must be writable regular files: {path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w") as stream:
            json.dump(updated, stream, indent=2)
            stream.write("\n")
        os.replace(temporary, path)
    finally:
        Path(temporary).unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--assets", required=True, type=Path)
    parser.add_argument("--home", type=Path, default=Path.home())
    args = parser.parse_args()
    update_json(args.home / ".config/zed/settings.json", {
        "ui_font_family": "IoskeleyMonoTerm Nerd Font", "ui_font_size": 16,
        "buffer_font_family": "IoskeleyMonoTerm Nerd Font", "buffer_font_size": 15,
        "terminal": {"font_family": "IoskeleyMonoTerm Nerd Font"},
        "markdown_preview": {"font_family": "Inter"},
        "theme": {"mode": "dark", "dark": "Victus Graphite"},
    })
    registry = args.home / ".config/obsidian/obsidian.json"
    if registry.exists():
        for vault in json.loads(registry.read_text()).get("vaults", {}).values():
            if not isinstance(vault, dict) or not vault.get("path"):
                continue
            root = Path(vault["path"])
            if not root.is_dir():
                continue
            theme = root / ".obsidian/themes/Victus Graphite"
            theme.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(args.assets / "obsidian.css", theme / "theme.css")
            shutil.copyfile(args.assets / "obsidian-manifest.json", theme / "manifest.json")
            update_json(root / ".obsidian/appearance.json", {
                "cssTheme": "Victus Graphite",
                "monospaceFontFamily": "IoskeleyMonoTerm Nerd Font Mono,JetBrainsMono Nerd Font Mono",
            })


if __name__ == "__main__":
    main()

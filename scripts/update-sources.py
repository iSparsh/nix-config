#!/usr/bin/env python3
"""Check official release sources; optionally update pins before flake locking."""
import argparse
import base64
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parent.parent
TAG_INPUTS = {
    "dux-search": "duxlabs-dev/dux-search",
    "dux-files": "duxlabs-dev/dux-files",
    "dux-greeter": "duxlabs-dev/dux-greeter",
    "hex": "anomalyco/hex",
    "opencode": "anomalyco/opencode",
    "zed": "zed-industries/zed",
    "artcraft-launcher": "storytold/craft-launcher",
}


def github(path):
    return json.loads(subprocess.check_output(["gh", "api", path], text=True))


def latest(repo):
    releases = github(f"repos/{repo}/releases?per_page=100")
    eligible = [r for r in releases if not r["prerelease"] and not r["draft"]]
    if repo == "anomalyco/opencode":
        eligible = [r for r in eligible if r["tag_name"].startswith("v2.")]
    if not eligible:
        raise RuntimeError(f"No suitable release for {repo}")
    return eligible[0]


def pin(asset):
    digest = asset.get("digest", "")
    if not digest.startswith("sha256:"):
        raise RuntimeError(f"Missing SHA256 digest for {asset['name']}")
    return {
        "url": asset["browser_download_url"],
        "hash": "sha256-" + base64.b64encode(bytes.fromhex(digest.split(":", 1)[1])).decode(),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    flake = (ROOT / "flake.nix").read_text()
    for name, repo in TAG_INPUTS.items():
        release = latest(repo)
        replacement = f'    {name}.url = "github:{repo}/{release["tag_name"]}";'
        flake, count = re.subn(rf'    {re.escape(name)}\.url = "[^"]+";', replacement, flake)
        if count != 1:
            raise RuntimeError(f"Expected exactly one flake input for {name}")
        print(f'{name}: {release["tag_name"]}')
    packages = json.loads((ROOT / "packages.json").read_text())
    for name, package in packages.items():
        release = latest(package["repo"])
        assets = {a["name"]: a for a in release["assets"]}
        tag = release["tag_name"]
        if name == "helium":
            package["version"] = tag.removeprefix("v")
            for system, arch in [("x86_64-linux", "x86_64"), ("aarch64-linux", "arm64")]:
                package["assets"][system] = pin(assets[f'helium-{package["version"]}-{arch}.AppImage'])
        elif name == "ioskeley":
            package["version"] = tag.removeprefix("v")
            package.update(pin(assets["IoskeleyMono-Term-NerdFont.zip"]))
        elif name == "apple-emoji":
            package["version"] = tag
            package.update(pin(assets["AppleColorEmoji-Linux.ttf"]))
        print(f'{name}: {tag}')
    if args.apply:
        (ROOT / "flake.nix").write_text(flake)
        (ROOT / "packages.json").write_text(json.dumps(packages, indent=2) + "\n")
        print("Pins updated. Run nix flake update, format, and validate before committing.")


if __name__ == "__main__":
    main()

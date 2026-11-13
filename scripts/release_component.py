import re
import subprocess
from pathlib import Path

import yaml
from packaging.version import InvalidVersion, Version

COMPONENTS: dict[str, tuple[str, str]] = {
    "extension": ("extensions", "extension.yml"),
    "preset": ("presets", "preset.yml"),
}


def git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        capture_output=True,
        check=False,
        text=True,
    )
    if result.returncode:
        detail = result.stderr.strip() or result.stdout.strip()
        raise SystemExit(f"git {' '.join(args)} failed: {detail}")
    return result.stdout.strip()


def release_component(
    kind: str, component_id: str, version: str, _dry_run: bool = False
) -> None:
    try:
        package_root, manifest_name = COMPONENTS[kind]
    except KeyError as exc:
        raise SystemExit(f"Unsupported release component: {kind!r}") from exc

    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", component_id):
        raise SystemExit(f"Invalid {kind} ID: {component_id!r}")
    try:
        Version(version)
    except InvalidVersion as exc:
        raise SystemExit(f"Invalid PEP 440 version: {version!r}") from exc

    package_dir = Path(package_root) / component_id
    manifest_path = package_dir / manifest_name
    if not manifest_path.is_file():
        raise SystemExit(f"No {kind} manifest found at {manifest_path}")

    manifest = yaml.safe_load(manifest_path.read_text(encoding="utf-8"))
    if not isinstance(manifest, dict) or not isinstance(manifest.get(kind), dict):
        raise SystemExit(f"Invalid {kind} manifest: {manifest_path}")
    component = manifest[kind]
    if component.get("id") != component_id:
        raise SystemExit(
            f"Manifest ID {component.get('id')!r} does not match {component_id!r}"
        )
    if str(component.get("version")) != version:
        raise SystemExit(
            f"Manifest version {component.get('version')!r} does not match {version!r}"
        )

    for other_kind, (other_root, other_manifest) in COMPONENTS.items():
        if other_kind == kind:
            continue
        if (Path(other_root) / component_id / other_manifest).is_file():
            raise SystemExit(
                f"Component ID {component_id!r} is also used by a {other_kind}; "
                "release IDs must be unique across extensions and presets."
            )

    tag = f"{component_id}-v{version}"
    if git("status", "--porcelain", "--untracked-files=all"):
        raise SystemExit("Commit or discard all working-tree changes before releasing.")

    if git("tag", "--list", tag):
        raise SystemExit(f"Local tag {tag!r} already exists.")
    if git("ls-remote", "--tags", "origin", f"refs/tags/{tag}"):
        raise SystemExit(f"Remote tag {tag!r} already exists.")

    if _dry_run:
        print(f"Would create and push {tag}; GitHub Actions will publish the release.")
        return

    git(
        "tag",
        "--annotate",
        "--message",
        f"Release {kind} {component_id} {version}",
        tag,
    )
    try:
        git("push", "origin", tag)
    except SystemExit as exc:
        raise SystemExit(
            f"{exc}\nThe tag was created locally but not pushed; resolve the issue "
            f"and push it with `git push origin {tag}`."
        ) from exc
    print(f"Pushed {tag}; the GitHub Actions release workflow will publish it.")


def release_extension(extension: str, version: str, _dry_run: bool = False) -> None:
    release_component("extension", extension, version, _dry_run)


def release_preset(preset: str, version: str, _dry_run: bool = False) -> None:
    release_component("preset", preset, version, _dry_run)

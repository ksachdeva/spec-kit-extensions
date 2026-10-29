#!/usr/bin/env bash

set -euo pipefail

CURRENT="${1:-$(hostname)}"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

copy_state() {
  local source_dir=$1
  local volume=$2
  local file_list=$3
  local owner_uid
  local owner_gid

  owner_uid=$(docker exec "$CURRENT" id -u vscode)
  owner_gid=$(docker exec "$CURRENT" id -g vscode)

  docker exec "$CURRENT" bash -c '
    set -euo pipefail
    cd "$1"
    mapfile -t files < <(
      while IFS= read -r pattern; do
        compgen -G "$pattern" || true
      done < "$2"
    )
    if ((${#files[@]})); then
      tar -czf - "${files[@]}"
    else
      tar -czf - --files-from /dev/null
    fi
  ' bash "$source_dir" "$file_list" \
    | docker run --rm -i -v "$volume:/data" alpine \
        sh -c 'tar -xzf - -C /data && chown -R "$1:$2" /data' \
        sh "$owner_uid" "$owner_gid"
}

copy_state /home/vscode/.copilot devcontainer-copilot \
  "$SCRIPT_DIR/copilot-state-files.txt"

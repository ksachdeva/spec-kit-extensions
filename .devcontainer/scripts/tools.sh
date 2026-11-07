#!/usr/bin/env zsh

# Exit immediately on error, treat unset variables as an error, and fail if any command in a pipeline fails.
set -euo pipefail

USER=vscode

# Function to run a command and show logs only on error
run_command() {
    local command_to_run="$*"
    local output
    local exit_code

    # Capture all output (stdout and stderr)
    output=$(eval "$command_to_run" 2>&1) || exit_code=$?
    exit_code=${exit_code:-0}

    if [ $exit_code -ne 0 ]; then
        echo -e "\033[0;31m[ERROR] Command failed (Exit Code $exit_code): $command_to_run\033[0m" >&2
        echo -e "\033[0;31m$output\033[0m" >&2

        exit $exit_code
    fi
}

echo "Configuring opencode storage ..."
run_command "sudo mkdir -p /opencode-storage"
run_command "sudo chown -R ${USER} /opencode-storage"

echo "install copilot ..."
run_command "npm install -g @github/copilot"

echo "install opencode ..."
run_command "npm install -g --allow-scripts=@opencode/cli @opencode/cli"

echo "install hunk ..."
run_command "npm install -g hunkdiff"

echo "install leaf ..."
run_command "npm install -g @rivolink/leaf"

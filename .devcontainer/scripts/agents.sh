#!/usr/bin/env zsh

USER=vscode

echo "Configuring opencode storage ..."
sudo mkdir -p /opencode-storage
sudo chown -R ${USER} /opencode-storage

echo "install copilot ..."
npm install -g @github/copilot

echo "install opencode ..."
npm install -g --allow-scripts=@opencode/cli @opencode/cli

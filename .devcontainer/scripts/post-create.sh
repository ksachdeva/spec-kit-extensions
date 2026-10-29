#!/usr/bin/env bash

USERNAME=vscode
SCRIPTS_DIR=$(realpath $(dirname "$0"))
BASE_DIR=$(dirname "$SCRIPTS_DIR")

echo "changing zshrc theme to ys ..."
sed -i s/^ZSH_THEME=".\+"$/ZSH_THEME=\"ys\"/g ~/.zshrc

echo "sym link zsh_history ..."
mkdir -p /commandhistory
sudo touch /commandhistory/.zsh_history
sudo chown -R $USERNAME /commandhistory

SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history"
echo "$SNIPPET" >> "/home/$USERNAME/.zshrc"

bash "$SCRIPTS_DIR"/poe.sh
bash "$SCRIPTS_DIR"/cloudflare-trust.sh
bash "$SCRIPTS_DIR"/docker-completion.sh
bash "$SCRIPTS_DIR"/uv.sh
bash "$SCRIPTS_DIR"/agents.sh

echo "install pre-commit hooks ..."
uv run pre-commit install

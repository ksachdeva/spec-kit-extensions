#!/usr/bin/env zsh

echo "uv sync ..."
uv sync

echo "Configuring uv tab completion..."
echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
echo 'eval "$(uvx --generate-shell-completion zsh)"' >> ~/.zshrc
echo -e "Configuring uv tab completion... \033[32;1mdone\033[0m"

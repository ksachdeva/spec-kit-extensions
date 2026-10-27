#!/usr/bin/env zsh

echo "Configuring Docker tab completion..."
mkdir -p ~/.oh-my-zsh/completions
docker completion zsh > ~/.oh-my-zsh/completions/_docker
echo -e "Configuring Docker tab completion... \033[32;1mdone\033[0m"

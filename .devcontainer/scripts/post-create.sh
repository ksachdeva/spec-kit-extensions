#!/usr/bin/env bash

USERNAME=vscode

echo "changing zshrc theme to ys ..."
sed -i s/^ZSH_THEME=".\+"$/ZSH_THEME=\"ys\"/g ~/.zshrc

echo "sym link zsh_history ..."
mkdir -p /commandhistory
sudo touch /commandhistory/.zsh_history
sudo chown -R $USERNAME /commandhistory

SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history"
echo "$SNIPPET" >> "/home/$USERNAME/.zshrc"

mkdir -p "$HOME/.local/bin"

echo "Creating local bin scripts for poe and poe-infra..."
cat > "$HOME/.local/bin/poe" <<'EOF'
#!/usr/bin/env bash
exec uv run poe "$@"
EOF

chmod +x "$HOME/.local/bin/poe"

bash "$SCRIPTS_DIR"/cloudflare-trust.sh
bash "$SCRIPTS_DIR"/docker-completion.sh
bash "$SCRIPTS_DIR"/uv.sh

echo "install pre-commit hooks ..."
uv run pre-commit install

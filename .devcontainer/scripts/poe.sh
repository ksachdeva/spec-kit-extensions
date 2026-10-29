#!/usr/bin/env zsh

mkdir -p "$HOME/.local/bin"

echo "Creating local bin scripts for poe..."
cat > "$HOME/.local/bin/poe" <<'EOF'
#!/usr/bin/env bash
exec uv run poe "$@"
EOF

chmod +x "$HOME/.local/bin/poe"

echo "Creating zsh completions for poe ..."
mkdir -p ~/.oh-my-zsh/completions
$HOME/.local/bin/poe _zsh_completion > ~/.oh-my-zsh/completions/_poe

rm -f "$HOME"/.zcompdump*

#!/usr/bin/env bash
# install.sh — installs `dockgen` (Docker Project Scaffold) as a system command
set -euo pipefail

C='\033[1;36m' G='\033[1;32m' Y='\033[1;33m' R='\033[0m' B='\033[1m' D='\033[2m'
CMD_NAME="dockgen"
BIN_DIR="$HOME/.local/bin"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER="$BIN_DIR/$CMD_NAME"

printf "\n${C}╭──────────────────────────────────────────╮${R}\n"
printf "${C}│${R}  ${B}dockgen${R} — Docker Project Scaffold     ${C}│${R}\n"
printf "${C}╰──────────────────────────────────────────╯${R}\n\n"

# ── 1. Create ~/.local/bin if needed ───────────────────────────────────────
mkdir -p "$BIN_DIR"

# ── 2. Write wrapper ───────────────────────────────────────────────────────
cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
exec "$REPO_DIR/create_project.sh" "\$@"
EOF
chmod +x "$WRAPPER"
printf "  ${G}✓${R}  Created ${B}$WRAPPER${R}\n"

# ── 3. Add ~/.local/bin to PATH (zsh) ─────────────────────────────────────
ZSHRC="$HOME/.zshrc"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
if ! grep -qF '.local/bin' "$ZSHRC" 2>/dev/null; then
  printf '\n# Added by dockgen installer\n%s\n' "$PATH_LINE" >> "$ZSHRC"
  printf "  ${G}✓${R}  Added ${B}~/.local/bin${R} to PATH in ${B}~/.zshrc${R}\n"
else
  printf "  ${D}·  ~/.local/bin already in PATH (zshrc)${R}\n"
fi

# ── 4. Add to bash_profile too (for bash users) ────────────────────────────
BASH_PROF="$HOME/.bash_profile"
if [[ -f "$BASH_PROF" ]] && ! grep -qF '.local/bin' "$BASH_PROF" 2>/dev/null; then
  printf '\n# Added by dockgen installer\n%s\n' "$PATH_LINE" >> "$BASH_PROF"
  printf "  ${G}✓${R}  Added ${B}~/.local/bin${R} to PATH in ${B}~/.bash_profile${R}\n"
fi

# ── Done ───────────────────────────────────────────────────────────────────
printf "\n${G}  All done!${R}\n\n"
printf "  Reload your shell or run:\n"
printf "    ${Y}source ~/.zshrc${R}\n\n"
printf "  Then launch with:\n"
printf "    ${B}${Y}dockgen${R}\n\n"

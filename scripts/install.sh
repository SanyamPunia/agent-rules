#!/usr/bin/env bash
# Install these rules into ~/.claude so they load in every Claude Code session.
#
#   ./scripts/install.sh [--copy] [--force]
#
#   --copy   copy the rule files instead of symlinking them. Symlinks are the
#            default so `git pull` in this repo updates every project at once.
#   --force  overwrite an existing global CLAUDE.md instead of backing it up
#            and prepending.
#
# Installs base.md and frontend.md as always-on. Every other module stays
# opt-in, imported per project by scripts/init-rules.sh.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
MARKER="<!-- agent-rules:managed -->"
MODE="link"
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --copy)    MODE="copy" ;;
    --force)   FORCE=1 ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)         echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

mkdir -p "$CLAUDE_DIR/rules" "$CLAUDE_DIR/commands"

place() {  # place <src> <dest>
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    cp "$dest" "$dest.bak"
    echo "  backed up existing $(basename "$dest") to $(basename "$dest").bak"
  fi
  rm -f "$dest"
  if [ "$MODE" = "copy" ]; then cp "$src" "$dest"; else ln -s "$src" "$dest"; fi
}

echo "Installing rules into $CLAUDE_DIR ($MODE mode)"
for f in "$REPO"/base/*.md; do
  place "$f" "$CLAUDE_DIR/rules/$(basename "$f")"
done
place "$REPO/commands/init-rules.md" "$CLAUDE_DIR/commands/init-rules.md"

# ------------------------------------------------------------ global CLAUDE.md
GLOBAL="$CLAUDE_DIR/CLAUDE.md"
BLOCK="$MARKER
# Global rules

These load in every session. A project's own CLAUDE.md may add to them or
override a specific parameter, never silently drop a rule.

@~/.claude/rules/base.md

@~/.claude/rules/frontend.md

Optional modules live in ~/.claude/rules and are imported per project:
typescript.md, state.md, data.md, seo.md, ai-features.md, three-js.md.
Scaffold a project with the /init-rules command.
$MARKER"

if [ ! -f "$GLOBAL" ]; then
  printf '%s\n' "$BLOCK" > "$GLOBAL"
  echo "  wrote $GLOBAL"
elif grep -qF "$MARKER" "$GLOBAL"; then
  echo "  $GLOBAL already managed, left alone"
elif [ "$FORCE" -eq 1 ]; then
  cp "$GLOBAL" "$GLOBAL.bak"
  printf '%s\n' "$BLOCK" > "$GLOBAL"
  echo "  replaced $GLOBAL (backup at CLAUDE.md.bak)"
else
  cp "$GLOBAL" "$GLOBAL.bak"
  printf '%s\n\n%s\n' "$BLOCK" "$(cat "$GLOBAL")" > "$GLOBAL"
  echo "  prepended to existing $GLOBAL (backup at CLAUDE.md.bak)"
fi

# ------------------------------------------------------------------ git config
if [ -f "$CLAUDE_DIR/settings.json" ] && ! grep -q '"includeCoAuthoredBy"' "$CLAUDE_DIR/settings.json"; then
  echo
  echo "Note: base.md forbids AI co-author trailers. To enforce it in the harness, add"
  echo '      "includeCoAuthoredBy": false   to '"$CLAUDE_DIR/settings.json"
fi

echo
echo "Done. Start a new Claude Code session to pick the rules up."
echo "Scaffold a project with: $REPO/scripts/init-rules.sh"

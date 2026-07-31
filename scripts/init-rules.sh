#!/usr/bin/env bash
# Scaffold a project's CLAUDE.md from the installed rule modules.
#
#   init-rules.sh [dir] [--vendor] [--force] [--with <module>]...
#
#   --with <m>  add an optional module: typescript, state, data, seo,
#               ai-features, three-js. Repeatable.
#   --vendor    copy the rule text into the project instead of importing it
#               from ~/.claude/rules. Use for public or shared repos.
#   --force     replace an existing CLAUDE.md.
#
# base.md is always imported. frontend.md is imported when React or Tailwind
# is detected. Everything else is opt-in via --with.

set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
RULES_DIR="$CLAUDE_DIR/rules"
REPO_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/base"
[ -d "$REPO_BASE" ] && RULES_DIR="$REPO_BASE"

DIR="."
VENDOR=0
FORCE=0
FRONTEND=0
EXTRAS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --with)      EXTRAS+=("$2"); shift 2 ;;
    --frontend)  FRONTEND=1; shift ;;
    --vendor)    VENDOR=1; shift ;;
    --force)     FORCE=1; shift ;;
    -h|--help)   sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)          echo "unknown flag: $1" >&2; exit 1 ;;
    *)           DIR="$1"; shift ;;
  esac
done

cd "$DIR"
PROJECT="$(basename "$PWD")"

# ------------------------------------------------------------- detect frontend
if [ "$FRONTEND" -eq 0 ] && [ -f package.json ] \
   && grep -qE '"(react|next|tailwindcss)"[[:space:]]*:' package.json; then
  FRONTEND=1
fi

# ------------------------------------------------------------- detect defaults
pm="pnpm"
[ -f package-lock.json ] && pm="npm"
[ -f yarn.lock ]         && pm="yarn"
[ -f bun.lockb ]         && pm="bun"

icons="TODO: declare one"
if [ -f package.json ]; then
  grep -q '"@phosphor-icons/react"' package.json && icons='`@phosphor-icons/react` (`*Icon`-suffixed exports only)'
  grep -q '"lucide-react"'          package.json && icons='`lucide-react`'
fi

cn_path="TODO"
for p in lib/utils.ts lib/utils.tsx src/lib/utils.ts src/lib/utils.tsx; do
  [ -f "$p" ] && cn_path="$p"
done

css_path="TODO"
for p in app/globals.css src/app/globals.css src/styles/index.css styles/globals.css; do
  [ -f "$p" ] && css_path="$p"
done

gate="TODO"
if [ -f package.json ]; then
  grep -q '"check"' package.json && gate="$pm check"
  grep -q '"all"'   package.json && gate="$pm all"
fi

# ------------------------------------------------------------------ rule links
link_for() {  # link_for <module>
  if [ "$VENDOR" -eq 1 ]; then echo "@.claude/rules/$1.md"; else echo "@~/.claude/rules/$1.md"; fi
}

MODULES=(base)
[ "$FRONTEND" -eq 1 ] && MODULES+=(frontend)
for m in ${EXTRAS+"${EXTRAS[@]}"}; do MODULES+=("$m"); done

for m in "${MODULES[@]}"; do
  [ -f "$RULES_DIR/$m.md" ] || { echo "no such module: $m (looked in $RULES_DIR)" >&2; exit 1; }
done

if [ "$VENDOR" -eq 1 ]; then
  mkdir -p .claude/rules
  for m in "${MODULES[@]}"; do cp -L "$RULES_DIR/$m.md" ".claude/rules/$m.md"; done
fi

# -------------------------------------------------------------- write the file
if [ -f CLAUDE.md ] && [ "$FORCE" -eq 0 ]; then
  echo "CLAUDE.md already exists in $PWD. Re-run with --force to replace it." >&2
  exit 1
fi

{
  echo "# CLAUDE.md"
  echo
  for m in "${MODULES[@]}"; do echo "$(link_for "$m")"; echo; done
  echo "## Project overview"
  echo
  echo "$PROJECT. TODO: one paragraph on what this is and who it is for."
  echo
  echo "## Commands"
  echo
  echo '```bash'
  echo "$pm dev"
  echo "$gate    # the gate for any push or deploy"
  echo '```'
  echo

  if [ "$FRONTEND" -eq 1 ]; then
    cat <<EOF
## Stack declaration

Fills in the parameters the shared frontend rules reference. Everything else comes from those rules.

| Parameter | This project |
|---|---|
| Package manager | \`$pm\` |
| Icon library | $icons |
| Color system | semantic tokens in \`$css_path\`. Raw palette utilities and hex are banned. |
| Type scale | TODO: a named scale, or \`text-xs\` / \`text-sm\` |
| Default radius | TODO: controls, cards, pills |
| Focus pattern | TODO: the exact class string, ending in \`transition-all duration-200\` |
| Body font | TODO |
| Class helper | \`cn()\` from \`$cn_path\` |
| Toasts | TODO |
| Build gate | \`$gate\` |
| Design system doc | TODO |

EOF
  fi

  cat <<'EOF'
## Architecture

TODO: the seams and the non-obvious decisions only. Do not restate what reading the tree already tells you.

## Gotchas

TODO: the things that burned you once. Each one earns its line by having cost real time.
EOF
} > CLAUDE.md

# AGENTS.md points at the same content for Cursor, Codex, and friends.
if [ ! -e AGENTS.md ] || [ "$FORCE" -eq 1 ]; then
  rm -f AGENTS.md
  ln -s CLAUDE.md AGENTS.md
fi

echo "Wrote $PWD/CLAUDE.md with modules: ${MODULES[*]}"
echo "Linked AGENTS.md -> CLAUDE.md"
[ "$VENDOR" -eq 1 ] && echo "Vendored rule text into .claude/rules/"
echo "Fill in the TODOs."

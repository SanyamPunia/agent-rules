#!/usr/bin/env sh
# One-command install. Clones (or updates) the checkout, then installs.
#
#   curl -fsSL https://raw.githubusercontent.com/SanyamPunia/agent-rules/main/scripts/bootstrap.sh | sh
#
# Any flags are forwarded to install.sh, for example:
#
#   curl -fsSL .../bootstrap.sh | sh -s -- --copy
#
# Override the checkout location with AGENT_RULES_DIR.

set -eu

REPO="https://github.com/SanyamPunia/agent-rules.git"
DEST="${AGENT_RULES_DIR:-$HOME/.agent-rules}"

command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 1; }

if [ -d "$DEST/.git" ]; then
  echo "Updating existing checkout at $DEST"
  git -C "$DEST" pull --ff-only --quiet || echo "  could not fast-forward, using the checkout as-is"
else
  echo "Cloning into $DEST"
  git clone --depth 1 --quiet "$REPO" "$DEST"
fi

exec "$DEST/scripts/install.sh" "$@"

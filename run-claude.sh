#!/bin/bash
# Start Claude Code connected to a local LLM via the proxy

LITELLM_PORT="${LITELLM_PORT:-4000}"

# Check that the proxy is running
if ! curl -sf "http://localhost:${LITELLM_PORT}/health" > /dev/null 2>&1; then
  echo "Error: proxy is not running."
  echo "Start it first in another terminal: ./run-proxy.sh"
  echo "To use a different port: LITELLM_PORT=4001 ./run-proxy.sh"
  exit 1
fi

# Resolve the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# NODE_BIN: bin directory of the Node.js managed by nvm
NODE_BIN="$(dirname "$(which node)")"

# Write a minimal PATH to a temp file for Safehouse.
# Passing the full PATH via --env causes Node.js to lstat() paths like
# ~/.antigravity and ~/.cargo, which results in EPERM inside the sandbox.
ENV_FILE="$(mktemp)"
cat > "$ENV_FILE" <<EOF
export PATH="${NODE_BIN}:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
export ANTHROPIC_BASE_URL="http://localhost:${LITELLM_PORT}"
export ANTHROPIC_API_KEY="local-secret"
EOF

# Launch Claude Code inside Safehouse, restricting access to this directory only.
# --dangerously-skip-permissions: Safehouse provides the sandbox, so Claude Code's
#   own permission prompts are skipped.
# --env=FILE: pass only the minimal PATH and required env vars.
# --add-dirs-ro ~/.nvm: allow read access to the nvm Node.js binaries.
safehouse \
  --workdir "$SCRIPT_DIR" \
  --add-dirs-ro ~/.nvm \
  --env="$ENV_FILE" \
  -- claude --dangerously-skip-permissions

rm -f "$ENV_FILE"

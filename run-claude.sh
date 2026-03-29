#!/bin/bash
# Start Claude Code connected to a local LLM via Safehouse sandbox.
#
# llamafile v0.10.0+ natively supports the Anthropic Messages API (/v1/messages),
# so Claude Code can connect to it directly without a proxy.
#
# If you need a proxy (e.g. for protocol debugging or using an older llamafile),
# set LITELLM_PORT and uncomment the proxy section below.

LLAMA_PORT="${LLAMA_PORT:-8080}"

# --- Option A: Direct connection to llamafile (default) ---
ANTHROPIC_BASE_URL="http://localhost:${LLAMA_PORT}"

# --- Option B: Via proxy (run-proxy.sh must be running first) ---
# LITELLM_PORT="${LITELLM_PORT:-4000}"
# ANTHROPIC_BASE_URL="http://localhost:${LITELLM_PORT}"

# Check that the LLM server (or proxy) is reachable
if ! curl -sf "${ANTHROPIC_BASE_URL}/health" > /dev/null 2>&1; then
  echo "Error: cannot reach ${ANTHROPIC_BASE_URL}"
  echo "Start the LLM server first: ./run-llama.sh"
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
export ANTHROPIC_BASE_URL="${ANTHROPIC_BASE_URL}"
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

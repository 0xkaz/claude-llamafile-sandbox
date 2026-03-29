#!/bin/bash
# Start the Anthropic → OpenAI translation proxy (proxy.py).

LLAMA_PORT="${LLAMA_PORT:-8080}"
PROXY_PORT="${LITELLM_PORT:-4000}"

export LLAMAFILE_URL="http://localhost:${LLAMA_PORT}"
export PROXY_PORT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! python3 -c "import fastapi, uvicorn, httpx" 2>/dev/null; then
  echo "Error: missing dependencies."
  echo "  pip install fastapi uvicorn httpx"
  exit 1
fi

echo "Starting proxy on port ${PROXY_PORT} → llamafile on port ${LLAMA_PORT} ..."
python3 "$SCRIPT_DIR/proxy.py"

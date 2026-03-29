#!/bin/bash
# Start the model using llama-server (Homebrew llama.cpp).
# Alternative to llamafile. Native arm64 build — faster on Apple Silicon.
# Requires: brew install llama.cpp

PORT="${LLAMA_PORT:-8080}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------------------------
# Model selection (match the choice made in download-model.sh)
# ---------------------------------------------------------------------------

# --- Qwen3-1.7B (recommended: ~1.8GB, fastest) ---
MODEL_FILE="${SCRIPT_DIR}/Qwen3-1.7B-Q8_0.gguf"

# --- Qwen3-8B (balanced: ~5GB) ---
# MODEL_FILE="${SCRIPT_DIR}/Qwen3-8B-Q4_K_M.gguf"

# ---------------------------------------------------------------------------

if ! command -v llama-server &>/dev/null; then
  echo "Error: llama-server not found."
  echo "  brew install llama.cpp"
  exit 1
fi

if [ ! -f "$MODEL_FILE" ]; then
  echo "Error: $MODEL_FILE not found."
  echo "  Run ./download-model.sh first."
  exit 1
fi

echo "Starting llama-server on port $PORT ..."
echo "Model: $MODEL_FILE"

exec llama-server \
  -m "$MODEL_FILE" \
  --ctx-size 8192 \
  --parallel 1 \
  -ngl 99 \
  --host 127.0.0.1 \
  --port "$PORT"

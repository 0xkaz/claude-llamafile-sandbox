#!/bin/bash
# Start the llamafile server

PORT="${LLAMA_PORT:-8080}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------------------------
# Model selection (match the choice made in download-model.sh)
# ---------------------------------------------------------------------------

# --- Qwen3-1.7B (recommended: ~1GB, fastest) ---
# Runs a GGUF file using the 30B llamafile as a runtime
RUNTIME="${SCRIPT_DIR}/Qwen_Qwen3-30B-A3B-Q4_K_M.llamafile"
MODEL_FILE="${SCRIPT_DIR}/Qwen3-1.7B-Q8_0.gguf"
RUN_CMD="$RUNTIME -m $MODEL_FILE"

# --- Qwen3-8B (balanced: ~5GB) ---
# RUNTIME="${SCRIPT_DIR}/Qwen_Qwen3-30B-A3B-Q4_K_M.llamafile"
# MODEL_FILE="${SCRIPT_DIR}/Qwen3-8B-Q4_K_M.gguf"
# RUN_CMD="$RUNTIME -m $MODEL_FILE"

# --- Qwen3-30B-A3B MoE (high accuracy, ~18.6GB) ---
# RUNTIME="${SCRIPT_DIR}/qwen3-coder.llamafile"  # symlink
# RUN_CMD="$RUNTIME"

# ---------------------------------------------------------------------------

# File existence checks
if [[ "$RUN_CMD" == *" -m "* ]]; then
  # GGUF mode: need both the model file and the llamafile runtime
  if [ ! -f "$MODEL_FILE" ]; then
    echo "Error: model file not found: $MODEL_FILE"
    echo "  Run ./download-model.sh first."
    exit 1
  fi
  if [ ! -f "$RUNTIME" ]; then
    echo "Error: runtime not found: $RUNTIME"
    echo "  The Qwen3-30B-A3B llamafile is required as the runtime."
    echo "  Run ./download-model.sh first."
    exit 1
  fi
else
  # Standalone llamafile mode
  if [ ! -f "$RUNTIME" ]; then
    echo "Error: llamafile not found: $RUNTIME"
    echo "  Run ./download-model.sh first."
    exit 1
  fi
fi

echo "Starting llamafile server on port $PORT ..."
echo "Model: ${MODEL_FILE:-$RUNTIME}"

exec $RUN_CMD \
  --server \
  --nobrowser \
  --ctx-size 8192 \
  --parallel 1 \
  -ngl 99 \
  --host 127.0.0.1 \
  --port "$PORT"

#!/bin/bash
# Download and set up the model
# Switch models by toggling comments below

SYMLINK="qwen3-coder.llamafile"

# Check for huggingface-cli
if ! command -v huggingface-cli &>/dev/null; then
  echo "Error: huggingface-cli not found."
  echo "  pip install huggingface_hub"
  exit 1
fi

# ---------------------------------------------------------------------------
# Model selection (uncomment the model you want to use)
# ---------------------------------------------------------------------------

# --- Qwen3-1.7B (recommended: ~1.8GB, fastest) ---
REPO="Qwen/Qwen3-1.7B-GGUF"
FILENAME="Qwen3-1.7B-Q8_0.gguf"
IS_GGUF=true

# --- Qwen3-8B (balanced: ~5GB) ---
# REPO="Qwen/Qwen3-8B-GGUF"
# FILENAME="Qwen3-8B-Q4_K_M.gguf"
# IS_GGUF=true

# --- Qwen3-30B-A3B MoE (high accuracy, ~18.6GB) ---
# REPO="mozilla-ai/Qwen3-30B-A3B-llamafile"
# FILENAME="Qwen_Qwen3-30B-A3B-Q4_K_M.llamafile"
# IS_GGUF=false

# ---------------------------------------------------------------------------

# Skip download if the file already exists
if [ -f "$FILENAME" ]; then
  echo "$FILENAME already exists. Skipping download."
else
  echo "Downloading: $REPO / $FILENAME"
  huggingface-cli download "$REPO" "$FILENAME" --local-dir .
fi

# Make executable (only needed for llamafile, not GGUF)
if [ "$IS_GGUF" = false ]; then
  chmod +x "$FILENAME"
fi

# Create or update the symlink
if [ -L "$SYMLINK" ]; then
  echo "Updating symlink: $SYMLINK -> $FILENAME"
  ln -sf "$FILENAME" "$SYMLINK"
else
  ln -s "$FILENAME" "$SYMLINK"
  echo "Created symlink: $SYMLINK -> $FILENAME"
fi

echo "Done. Run ./run-llama.sh to start the server."

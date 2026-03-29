#!/bin/bash
# Install required tools
# Usage: ./setup.sh

set -e

echo "=== claude-llamafile-sandbox setup ==="

# Agent Safehouse
if command -v safehouse &>/dev/null; then
  echo "[OK] safehouse $(safehouse --version 2>&1 | head -1)"
else
  echo "[Installing] agent-safehouse..."
  brew install eugene1g/safehouse/agent-safehouse
  echo "[OK] safehouse installed"
fi

# Claude Code
if command -v claude &>/dev/null; then
  echo "[OK] claude found"
else
  echo "[Installing] claude-code..."
  npm install -g @anthropic-ai/claude-code
  echo "[OK] claude-code installed"
fi

# Dependencies for proxy.py (FastAPI / uvicorn / httpx)
if python3 -c "import fastapi, uvicorn, httpx" &>/dev/null; then
  echo "[OK] fastapi / uvicorn / httpx found"
else
  echo "[Installing] fastapi uvicorn httpx..."
  pip install fastapi uvicorn httpx
  echo "[OK] fastapi / uvicorn / httpx installed"
fi

# huggingface_hub (needed by download-model.sh)
if python3 -c "import huggingface_hub" &>/dev/null; then
  echo "[OK] huggingface_hub found"
else
  echo "[Installing] huggingface_hub..."
  pip install huggingface_hub
  echo "[OK] huggingface_hub installed"
fi

echo ""
echo "Setup complete. Next steps:"
echo "  ./download-model.sh   # Download model (~1.8GB, Qwen3-1.7B default)"
echo "  ./run-llama.sh        # Start AI server (Terminal 1)"
echo "  ./run-proxy.sh        # Start proxy (Terminal 2)"
echo "  ./run-claude.sh       # Start agent (Terminal 3)"

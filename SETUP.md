# Setup Instructions

How to run Claude Code with a local LLM (Qwen3) + Safehouse sandbox on Mac mini M4.

---

## Prerequisites

- macOS (Apple Silicon)
- Homebrew installed
- Node.js installed
- Python 3 / pip installed

---

## Step 1: Install Dependencies

```bash
./setup.sh
```

This installs and verifies:
- **Agent Safehouse** — macOS sandbox
- **Claude Code** — coding agent
- **huggingface_hub** — for downloading models
- **FastAPI / uvicorn / httpx** — only needed if using the optional proxy

---

## Step 2: Download the Model

The default model is **Qwen3-1.7B** (~1.8GB). You can switch models by editing the comments in `download-model.sh`.

```bash
./download-model.sh
```

| Model | Size | Speed | Use case |
|-------|------|-------|----------|
| Qwen3-1.7B (default) | ~1.8GB | Fastest | Quick responses |
| Qwen3-8B | ~5GB | Fast | Balanced |
| Qwen3-30B-A3B MoE | ~18.6GB | Slower | High accuracy |

Switch models by toggling comments in `download-model.sh` and `run-llama.sh` (or `run-llama-server.sh`).

---

## Step 3: Start (2 terminals)

### Terminal 1 — LLM server

Two options available — both use the same port:

```bash
./run-llama.sh          # llamafile version (no extra install needed)
# or
./run-llama-server.sh   # llama-server version (requires brew install llama.cpp, M4-optimized)
```

Ready when you see `llama server listening` or `main: server is listening`.

### Terminal 2 — Claude Code agent

```bash
./run-claude.sh
```

Claude Code connects directly to llamafile (which natively supports the Anthropic Messages API since v0.10.0) and starts inside the Safehouse sandbox. File access outside this directory is denied.

> **Note:** `run-claude.sh` uses `--dangerously-skip-permissions`, which disables Claude Code's own interactive permission prompts. This is safe here because Safehouse enforces sandbox restrictions at the OS level. Do not use this flag outside of a sandboxed environment.

---

## Optional: Using the Proxy

If you need to route Claude Code through `proxy.py` (e.g. for protocol debugging or older llamafile versions), a third terminal is required:

```bash
./run-proxy.sh        # Terminal 2 — proxy
./run-claude.sh       # Terminal 3 — agent (edit run-claude.sh to enable Option B)
```

In `run-claude.sh`, comment out Option A and uncomment Option B to point Claude Code at the proxy instead of llamafile directly.

---

## Customizing Ports

Override ports with environment variables if defaults conflict with other services.

| Variable | Default | Used by |
|----------|---------|---------|
| `LLAMA_PORT` | `8080` | llamafile server |
| `LITELLM_PORT` | `4000` | proxy (proxy.py) |

```bash
# Direct mode (2 terminals)
LLAMA_PORT=9080 ./run-llama.sh
LLAMA_PORT=9080 ./run-claude.sh

# Proxy mode (3 terminals)
LLAMA_PORT=9080 ./run-llama.sh
LLAMA_PORT=9080 LITELLM_PORT=4001 ./run-proxy.sh
LITELLM_PORT=4001 ./run-claude.sh
```

---

## File Structure

```
.
├── setup.sh            # Install dependencies
├── download-model.sh   # Download model
├── run-llama.sh        # Start LLM server (llamafile version)
├── run-llama-server.sh # Start LLM server (llama-server version, requires brew)
├── run-claude.sh       # Start agent
├── run-proxy.sh        # Start proxy (optional)
├── proxy.py            # Optional Anthropic→OpenAI conversion proxy
└── .safehouse          # Safehouse project config
```

Model files (created by `download-model.sh`, not committed to git):

| File | Size | Notes |
|------|------|-------|
| `Qwen3-1.7B-Q8_0.gguf` | ~1.8GB | Default model |
| `Qwen3-8B-Q4_K_M.gguf` | ~5GB | Optional |
| `Qwen_Qwen3-30B-A3B-Q4_K_M.llamafile` | ~18.6GB | Optional; also used as runtime for GGUF models |

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `qwen3-coder.llamafile not found` | Run `./download-model.sh` |
| `safehouse: command not found` | Run `./setup.sh` |
| `fastapi not found` | Run `./setup.sh` |
| Port 8080 already in use | Start with `LLAMA_PORT=9080` |
| Port 4000 already in use | Start with `LITELLM_PORT=4001` |
| Claude Code can't reach the model | Check that Terminal 1 shows `server is listening` |

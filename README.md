# claude-llamafile-sandbox

Run Claude Code fully offline using a local LLM, with file system access sandboxed at the OS level via [Agent Safehouse](https://github.com/eugene1g/safehouse).

No API calls leave your machine. No cloud costs.

## What this does

Claude Code normally requires the Anthropic API. This setup replaces that with a local Qwen3 model running via [llamafile](https://github.com/mozilla-ai/llamafile), and wraps the agent in a macOS sandbox so it can only read/write the project directory.

Two things make this work cleanly:

1. **llamafile v0.10.0+ natively supports the Anthropic Messages API** (`/v1/messages`) — Claude Code connects directly, no proxy needed.
2. **Safehouse enforces OS-level file isolation** — this makes it safe to run Claude Code with `--dangerously-skip-permissions`, eliminating interactive prompts while keeping the sandbox intact.

Tested on Mac mini M4 with Qwen3-1.7B (~1.8GB, Q8_0). Qwen3-1.7B works for simple tasks; 8B or 30B is recommended for serious coding work.

## Architecture

```
Claude Code
  → llamafile :8080  (Qwen3, Anthropic API native)
  [sandboxed by Safehouse — file access restricted to project directory]
```

| Tool | Role |
|------|------|
| [Qwen3-1.7B](https://huggingface.co/Qwen/Qwen3-1.7B-GGUF) (via Llamafile / llama-server) | Local LLM inference engine (default; 8B and 30B also supported) |
| [Claude Code](https://github.com/anthropics/claude-code) | Coding agent |
| [Agent Safehouse](https://github.com/eugene1g/safehouse) | macOS sandbox restricting file access to the project directory |
| [proxy.py](./proxy.py) | Optional Anthropic→OpenAI translation proxy |

## Quick Start

```bash
# 1. Install dependencies (first time only)
./setup.sh

# 2. Download the model (first time only)
./download-model.sh

# 3. Start the llamafile server (Terminal 1)
./run-llama.sh

# 4. Start the agent (Terminal 2)
./run-claude.sh
```

See [SETUP.md](./SETUP.md) for detailed instructions.

## File Structure

```
.
├── setup.sh            # Install dependencies
├── download-model.sh   # Download and set up the model
├── run-llama.sh        # Start LLM server (llamafile version)
├── run-llama-server.sh # Start LLM server (llama-server version, requires brew)
├── run-claude.sh       # Start the agent (with Safehouse)
├── run-proxy.sh        # Start the proxy (optional)
├── proxy.py            # Optional Anthropic→OpenAI conversion proxy
├── .safehouse          # Safehouse project config
├── README.md           # This file
└── SETUP.md            # Detailed setup instructions
```

## Security

Safehouse restricts Claude Code's file access to this directory only. Access to files outside this directory is denied by the sandbox.

`run-claude.sh` passes `--dangerously-skip-permissions` to Claude Code, which disables Claude Code's own interactive permission prompts. This is intentional: Safehouse enforces sandbox restrictions at the OS level, making the in-app prompts redundant. Do not use this flag outside of a sandboxed environment.

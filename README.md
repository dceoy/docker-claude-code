# docker-claude-code

Dockerfile for [Claude Code](https://code.claude.com/docs/en/overview)

## Usage

### Build the image

```sh
docker compose build
```

### Run interactively

```sh
ANTHROPIC_API_KEY=sk-ant-... docker compose run --rm claude-code
```

### Run with a prompt (non-interactive)

```sh
ANTHROPIC_API_KEY=sk-ant-... docker compose run --rm claude-code -p "explain this project"
```

### Mount a different working directory

```sh
HOST_WORK_DIR=/path/to/project ANTHROPIC_API_KEY=sk-ant-... docker compose run --rm claude-code
```

## Environment variables

| Variable | Description |
|---|---|
| `ANTHROPIC_API_KEY` | Anthropic API key (required) |
| `ANTHROPIC_MODEL` | Model override (e.g., `claude-sonnet-4-5-20250929`) |
| `CLAUDE_CODE_USE_BEDROCK` | Enable Amazon Bedrock (`1`) |
| `CLAUDE_CODE_USE_VERTEX` | Enable Google Vertex AI (`1`) |
| `HOST_WORK_DIR` | Host directory to mount as `/work` (default: `.`) |

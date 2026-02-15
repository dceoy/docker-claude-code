# docker-claude-code

Docker image and Docker Compose setup for running
[Claude Code](https://code.claude.com/docs/en/overview) in an isolated Ubuntu
container.

## Included tools

- [Claude Code](https://code.claude.com/docs/en/overview) CLI
- [GitHub CLI (`gh`)](https://cli.github.com/)
- `git`, `jq`, `npm`, `python3-pip`, `unzip`, `vim`, `zsh`
- Helper scripts: `print-github-tags`, `oh-my-zsh`

## Quick start

### Build the image

```sh
docker compose build
```

### Start an interactive container shell (default)

`compose.yml` runs `zsh -l` by default and mounts this repository at
`/workspace`.

```sh
OPENROUTER_API_KEY=sk-or-... docker compose run --rm claude-code
```

### Run Claude Code with a one-shot prompt

Override the compose entrypoint for one-shot usage:

```sh
OPENROUTER_API_KEY=sk-or-... \
docker compose run --rm --entrypoint claude claude-code \
  -p "explain this project"
```

## Runtime environment (`compose.yml`)

| Variable               | Default value               | Purpose                                       |
| ---------------------- | --------------------------- | --------------------------------------------- |
| `OPENROUTER_API_KEY`   | `${OPENROUTER_API_KEY:-}`   | API key used by the default OpenRouter wiring |
| `ANTHROPIC_BASE_URL`   | `https://openrouter.ai/api` | Routes Claude requests to OpenRouter          |
| `ANTHROPIC_AUTH_TOKEN` | `${OPENROUTER_API_KEY:-}`   | Token used with `ANTHROPIC_BASE_URL`          |
| `ANTHROPIC_API_KEY`    | `''` (explicitly empty)     | Kept empty to avoid conflicting provider auth |

To use Anthropic directly, override the OpenRouter-specific values at runtime.

```sh
ANTHROPIC_API_KEY=sk-ant-... \
docker compose run --rm \
  -e OPENROUTER_API_KEY= \
  -e ANTHROPIC_BASE_URL= \
  -e ANTHROPIC_AUTH_TOKEN= \
  --entrypoint claude claude-code \
  -p "explain this project"
```

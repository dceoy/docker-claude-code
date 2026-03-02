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

`compose.yml` now routes Claude Code through a local LiteLLM proxy:

`Claude Code -> LiteLLM (Anthropic-compatible endpoint) -> OpenRouter`

| Variable                          | Default value                                          | Purpose                                                   |
| --------------------------------- | ------------------------------------------------------ | --------------------------------------------------------- |
| `OPENROUTER_API_KEY`              | `${OPENROUTER_API_KEY:-}`                              | OpenRouter API key used by LiteLLM                        |
| `LITELLM_API_KEY`                 | `${LITELLM_API_KEY:-sk-litellm}`                       | Shared auth token between Claude Code and LiteLLM         |
| `LITELLM_OPENROUTER_OPUS_MODEL`   | `openrouter/openrouter/openrouter/free`                | OpenRouter free route mapped to Claude Code's Opus slot   |
| `LITELLM_OPENROUTER_SONNET_MODEL` | `openrouter/openrouter/openrouter/free`                | OpenRouter free route mapped to Claude Code's Sonnet slot |
| `LITELLM_OPENROUTER_HAIKU_MODEL`  | `openrouter/openrouter/openrouter/free`                | OpenRouter free route mapped to Claude Code's Haiku slot  |
| `ANTHROPIC_DEFAULT_OPUS_MODEL`    | `${ANTHROPIC_DEFAULT_OPUS_MODEL:-openrouter-opus}`     | Anthropic-facing model alias Claude Code uses for Opus    |
| `ANTHROPIC_DEFAULT_SONNET_MODEL`  | `${ANTHROPIC_DEFAULT_SONNET_MODEL:-openrouter-sonnet}` | Anthropic-facing model alias Claude Code uses for Sonnet  |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`   | `${ANTHROPIC_DEFAULT_HAIKU_MODEL:-openrouter-haiku}`   | Anthropic-facing model alias Claude Code uses for Haiku   |
| `ANTHROPIC_API_KEY`               | `''` (explicitly empty)                                | Kept empty to avoid conflicting provider auth             |

LiteLLM model alias definitions live in `litellm.config.yml`.

> Note: for LiteLLM's Anthropic-compatible endpoint, the free route is currently
> configured as `openrouter/openrouter/openrouter/free`.

### Example: pick non-Claude OpenRouter models

```sh
OPENROUTER_API_KEY=sk-or-... \
LITELLM_OPENROUTER_OPUS_MODEL=openrouter/google/gemini-2.5-pro-preview \
LITELLM_OPENROUTER_SONNET_MODEL=openrouter/openai/gpt-4.1 \
LITELLM_OPENROUTER_HAIKU_MODEL=openrouter/deepseek/deepseek-chat-v3-0324 \
docker compose run --rm --entrypoint claude claude-code \
  -p "explain this project"
```

To bypass LiteLLM and use Anthropic directly, clear the proxy-related Anthropic
settings at runtime and provide `ANTHROPIC_API_KEY`.

```sh
ANTHROPIC_API_KEY=sk-ant-... \
docker compose run --rm \
  -e ANTHROPIC_BASE_URL= \
  -e ANTHROPIC_AUTH_TOKEN= \
  -e ANTHROPIC_DEFAULT_OPUS_MODEL= \
  -e ANTHROPIC_DEFAULT_SONNET_MODEL= \
  -e ANTHROPIC_DEFAULT_HAIKU_MODEL= \
  --entrypoint claude claude-code \
  -p "explain this project"
```

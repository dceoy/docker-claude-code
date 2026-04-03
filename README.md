# docker-claude-code

Dockerfile and Compose files for Claude Code, with optional Codex CLI and
LiteLLM runtimes

## Included tools

- [Claude Code](https://code.claude.com/docs/en/overview) CLI
- OpenAI Codex CLI and the [`codex-plugin-cc`](https://github.com/openai/codex-plugin-cc) Claude plugin (auto-installed in `compose.claude-with-codex.yml`)
- [GitHub CLI (`gh`)](https://cli.github.com/)
- `git`, `jq`, `npm`, `pipx`, `python3-pip`, `ripgrep`, `unzip`, `uv`,
  `vim`, `wget`, `zsh`
- Helper scripts: `print-github-tags`, `oh-my-zsh`

## Quick start

### Build the image

```sh
docker compose build
```

To use the Codex-enabled or LiteLLM-enabled runtime instead, target the
alternate Compose file:

```sh
docker compose -f compose.claude-with-codex.yml build
docker compose -f compose.claude-and-litellm.yml build
```

`compose.yml` is a symlink to `compose.claude.yml`, so plain `docker compose`
commands keep using the default Claude Code runtime.

### Start an interactive Claude Code session (default)

`compose.yml` points to `compose.claude.yml`, which runs
`claude --dangerously-skip-permissions` directly, without LiteLLM, and mounts
this repository at `/workspace`. You can sign in interactively and keep the
session in the `claude-data` volume.

```sh
docker compose run --rm claude-code
```

### Start an interactive Claude Code session with Codex installed

`compose.claude-with-codex.yml` builds the `claude-with-codex` image target, so
the container includes `claude`, `codex`, and a user-scoped installation of
[`codex-plugin-cc`](https://github.com/openai/codex-plugin-cc) baked into the
image while keeping Claude state in `claude-data`, Codex state in
`codex-data`, and general app config in `config-data`.

```sh
docker compose -f compose.claude-with-codex.yml run --rm claude-code
```

The image installs the plugin during build with:

```sh
claude plugin marketplace add --scope=user openai/codex-plugin-cc
claude plugin install --scope=user codex@openai-codex
```

On first container start, Docker seeds the empty `claude-data` named volume
from the image contents, so the installed plugin persists with the rest of the
Claude state. Then run `/codex:setup` inside Claude Code. If you prefer
API-key auth over `codex login`, the Codex runtime also passes through
`OPENAI_API_KEY`.

If your existing `claude-data` volume was created before this image included
the plugin, recreate that volume once so Docker can seed it from the rebuilt
image.

### Run Claude Code with a one-shot prompt

```sh
ANTHROPIC_API_KEY=sk-ant-... \
docker compose run --rm claude-code \
  -p "explain this project"
```

## Runtime environments

### Default runtime (`compose.claude.yml`, via `compose.yml`)

- Runs only the `claude-code` container.
- Passes through `ANTHROPIC_API_KEY` for direct API-key authentication.
- Persists Claude Code state in `claude-data` and general app config in
  `config-data`.

### Codex-enabled runtime (`compose.claude-with-codex.yml`)

- Builds the `claude-with-codex` Dockerfile target so `codex` is installed
  alongside `claude`.
- Adds the OpenAI marketplace with `claude plugin marketplace add --scope=user openai/codex-plugin-cc` and installs `codex@openai-codex` during image build.
- Passes through `ANTHROPIC_API_KEY` for Claude Code and `GITHUB_TOKEN` for
  GitHub-backed workflows, plus `OPENAI_API_KEY` for Codex API-key auth.
- Persists Claude Code state in `claude-data`, Codex state in `codex-data`,
  and general app config in `config-data`.

### LiteLLM runtime (`compose.claude-and-litellm.yml`)

`compose.claude-and-litellm.yml` routes Claude Code through a local LiteLLM
proxy:

`Claude Code -> LiteLLM (Anthropic-compatible endpoint) -> Gemini (primary) -> Cerebras (fallback) -> Groq (fallback) -> OpenRouter (fallback)`

The LiteLLM proxy API is exposed on the host as `localhost:4000`.

Claude Code state is persisted in `claude-data`, and general app config is
persisted in `config-data`.

| Variable                                      | Default value                                                         | Purpose                                                    |
| --------------------------------------------- | --------------------------------------------------------------------- | ---------------------------------------------------------- |
| `OPENROUTER_API_KEY`                          | `${OPENROUTER_API_KEY:-}`                                             | OpenRouter API key used by LiteLLM                         |
| `OPENROUTER_SITE_URL`                         | `${OPENROUTER_SITE_URL:-https://github.com/dceoy/docker-claude-code}` | Referer header (`HTTP-Referer`) sent to OpenRouter         |
| `OPENROUTER_APP_NAME`                         | `${OPENROUTER_APP_NAME:-docker-claude-code}`                          | App title header (`X-Title`) sent to OpenRouter            |
| `CEREBRAS_API_KEY`                            | `${CEREBRAS_API_KEY:-}`                                               | Cerebras API key used by LiteLLM                           |
| `GROQ_API_KEY`                                | `${GROQ_API_KEY:-}`                                                   | Groq API key used by LiteLLM                               |
| `GEMINI_API_KEY`                              | `${GEMINI_API_KEY:-}`                                                 | Gemini API key used by LiteLLM                             |
| `LITELLM_API_KEY`                             | `${LITELLM_API_KEY:-sk-litellm}`                                      | Shared auth token between Claude Code and LiteLLM          |
| `LITELLM_ANTHROPIC_DISABLE_NO_PROVIDER_ERROR` | `'true'`                                                              | Allows Anthropic-compatible requests without Anthropic key |
| `LITELLM_CEREBRAS_OPUS_MODEL`                 | `cerebras/zai-glm-4.7`                                                | Cerebras model mapped to Claude Code's Opus slot           |
| `LITELLM_CEREBRAS_SONNET_MODEL`               | `cerebras/qwen-3-235b-a22b-instruct-2507`                             | Cerebras model mapped to Claude Code's Sonnet slot         |
| `LITELLM_CEREBRAS_HAIKU_MODEL`                | `cerebras/gpt-oss-120b`                                               | Cerebras model mapped to Claude Code's Haiku slot          |
| `LITELLM_GROQ_OPUS_MODEL`                     | `groq/openai/gpt-oss-120b`                                            | Groq model mapped to Claude Code's Opus slot               |
| `LITELLM_GROQ_SONNET_MODEL`                   | `groq/moonshotai/kimi-k2-instruct-0905`                               | Groq model mapped to Claude Code's Sonnet slot             |
| `LITELLM_GROQ_HAIKU_MODEL`                    | `groq/qwen/qwen3-32b`                                                 | Groq model mapped to Claude Code's Haiku slot              |
| `LITELLM_OPENROUTER_OPUS_MODEL`               | `openrouter/openrouter/openrouter/free`                               | OpenRouter free route mapped to Claude Code's Opus slot    |
| `LITELLM_OPENROUTER_SONNET_MODEL`             | `openrouter/openrouter/openrouter/free`                               | OpenRouter free route mapped to Claude Code's Sonnet slot  |
| `LITELLM_OPENROUTER_HAIKU_MODEL`              | `openrouter/openrouter/openrouter/free`                               | OpenRouter free route mapped to Claude Code's Haiku slot   |
| `LITELLM_GEMINI_OPUS_MODEL`                   | `gemini/gemini-3.1-pro-preview`                                       | Gemini model mapped to Claude Code's Opus slot             |
| `LITELLM_GEMINI_SONNET_MODEL`                 | `gemini/gemini-3-flash-preview`                                       | Gemini model mapped to Claude Code's Sonnet slot           |
| `LITELLM_GEMINI_HAIKU_MODEL`                  | `gemini/gemini-2.5-flash-lite`                                        | Gemini model mapped to Claude Code's Haiku slot            |
| `ANTHROPIC_DEFAULT_OPUS_MODEL`                | `${ANTHROPIC_DEFAULT_OPUS_MODEL:-gemini-opus}`                        | Anthropic-facing model alias Claude Code uses for Opus     |
| `ANTHROPIC_DEFAULT_SONNET_MODEL`              | `${ANTHROPIC_DEFAULT_SONNET_MODEL:-gemini-sonnet}`                    | Anthropic-facing model alias Claude Code uses for Sonnet   |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`               | `${ANTHROPIC_DEFAULT_HAIKU_MODEL:-gemini-haiku}`                      | Anthropic-facing model alias Claude Code uses for Haiku    |
| `ANTHROPIC_API_KEY`                           | `''` (explicitly empty)                                               | Kept empty to avoid conflicting provider auth              |

LiteLLM model alias definitions live in `litellm.config.yml`.

Gemini aliases are prioritized by default, and they fall back via Cerebras,
then Groq, then OpenRouter
(`gemini-* -> cerebras-* -> groq-* -> openrouter-*`).

> Note: for LiteLLM's Anthropic-compatible endpoint, the free route is currently
> configured as `openrouter/openrouter/openrouter/free`.

### Pin CLI versions at build time

All runtimes accept `CLAUDE_CODE_VERSION`, and the Codex-enabled runtime also
accepts `CODEX_CLI_VERSION`.

```sh
docker compose build --build-arg CLAUDE_CODE_VERSION=latest

docker compose -f compose.claude-with-codex.yml build \
  --build-arg CLAUDE_CODE_VERSION=latest \
  --build-arg CODEX_CLI_VERSION=latest
```

### Example: pick non-Claude OpenRouter models

```sh
OPENROUTER_API_KEY=sk-or-... \
ANTHROPIC_DEFAULT_OPUS_MODEL=openrouter-opus \
ANTHROPIC_DEFAULT_SONNET_MODEL=openrouter-sonnet \
ANTHROPIC_DEFAULT_HAIKU_MODEL=openrouter-haiku \
LITELLM_OPENROUTER_OPUS_MODEL=openrouter/google/gemini-2.5-pro-preview \
LITELLM_OPENROUTER_SONNET_MODEL=openrouter/openai/gpt-4.1 \
LITELLM_OPENROUTER_HAIKU_MODEL=openrouter/deepseek/deepseek-chat-v3-0324 \
docker compose -f compose.claude-and-litellm.yml run --rm claude-code \
  -p "explain this project"
```

### Example: route Claude Code slots to Gemini (direct Gemini API)

```sh
GEMINI_API_KEY=AIza... \
ANTHROPIC_DEFAULT_OPUS_MODEL=gemini-opus \
ANTHROPIC_DEFAULT_SONNET_MODEL=gemini-sonnet \
ANTHROPIC_DEFAULT_HAIKU_MODEL=gemini-haiku \
docker compose -f compose.claude-and-litellm.yml run --rm claude-code \
  -p "explain this project"
```

To use Anthropic directly instead of LiteLLM, use the default `compose.yml`
symlink, which points to `compose.claude.yml`.

```sh
ANTHROPIC_API_KEY=sk-ant-... \
docker compose run --rm claude-code \
  -p "explain this project"
```

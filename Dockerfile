FROM debian:bookworm-slim

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get -yqq update \
      && apt-get -yqq upgrade \
      && apt-get -yqq install --no-install-recommends --no-install-suggests \
        ca-certificates curl git jq openssh-client

RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
      && echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main' \
        > /etc/apt/sources.list.d/github-cli.list \
      && apt-get -yqq update \
      && apt-get -yqq install --no-install-recommends --no-install-suggests gh

RUN \
  --mount=type=cache,target=/root/.npm \
    curl -fsSL https://claude.ai/install.sh | bash

RUN \
  claude --version && gh --version

ENTRYPOINT ["claude"]

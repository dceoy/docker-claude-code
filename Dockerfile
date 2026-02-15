FROM debian:bookworm-slim

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN apt-get -qy update \
      && apt-get -qy install --no-install-recommends --no-install-suggests \
        ca-certificates curl git jq openssh-client \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN claude --version

ENTRYPOINT ["claude"]

#!/usr/bin/env bash

set -euox pipefail

cd "$(git rev-parse --show-toplevel)"

git ls-files -z -- '*.sh' '*.bash' '*.bats' | xargs -0 -t shellcheck
npx -y prettier --write './**/*.md'
zizmor --fix=safe .github/workflows
git ls-files -z -- '.github/workflows/*.yml' '.github/workflows/*.yaml' | xargs -0 -t actionlint
git ls-files -z -- '.github/workflows/*.yml' '.github/workflows/*.yaml' | xargs -0 -t yamllint -d '{"extends": "relaxed", "rules": {"line-length": "disable"}}'
checkov --framework=all --output=github_failed_only --directory=.
trivy filesystem --scanners vuln,secret,misconfig --skip-dirs .git .

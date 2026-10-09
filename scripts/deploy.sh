#!/usr/bin/env bash
# scripts/deploy.sh <staging|production> <commit>
#
# Runs the image of each Service at <commit>. Staging builds an image the first
# time it needs one; production only runs images staging already ran. A
# Service is redeployed only when the commit its image comes from changed.
set -euo pipefail

env=$1
sha=$(git rev-parse "$2")
state=${RT_STATE_DIR:-$HOME/.release-trial}
mkdir -p "$state"
case "$env" in
  staging) port=18080 ;;
  production) port=28080 ;;
  *) echo "unknown environment: $env" >&2; exit 2 ;;
esac

api=$(scripts/paths.sh tag api "$sha")
web=$(scripts/paths.sh tag web "$sha")
want=$(printf 'API_TAG=%s\nWEB_TAG=%s\nWEB_PORT=%s\n' "$api" "$web" "$port")
current="$state/$env.env"

if [ -f "$current" ] && [ "$(cat "$current")" = "$want" ]; then
  echo "Nothing to deploy: no Service changed at $sha."
  echo "$sha" > "$state/$env.sha"
  exit 0
fi

for pair in "api:$api" "web:$web"; do
  svc=${pair%%:*}
  tag=${pair#*:}
  if docker image inspect "rt-$svc:$tag" >/dev/null 2>&1; then continue; fi
  if [ "$env" != staging ]; then echo "rt-$svc:$tag never ran on staging." >&2; exit 1; fi
  echo "Building rt-$svc:$tag"
  git archive --format=tar "$tag" "$svc/" | docker build -q -t "rt-$svc:$tag" -f "$svc/Dockerfile" -
done

printf '%s\n' "$want" > "$current.next"
if docker compose -p "rt-$env" -f compose.yml --env-file "$current.next" up -d --no-build --wait --wait-timeout 60 \
  && curl -fsS "http://localhost:$port/health" >/dev/null; then
  mv "$current.next" "$current"
  echo "$sha" > "$state/$env.sha"
  echo "Deployed $sha to $env: api $api, web $web."
else
  echo "The deployment failed; the previous version stays." >&2
  if [ -f "$current" ]; then docker compose -p "rt-$env" -f compose.yml --env-file "$current" up -d --no-build --wait || true; fi
  rm -f "$current.next"
  exit 1
fi

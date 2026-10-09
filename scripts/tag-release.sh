#!/usr/bin/env bash
# scripts/tag-release.sh <commit>: tags what production now runs, after a healthy deployment.
set -euo pipefail

sha=$(git rev-parse "$1")
git fetch -q --tags origin
day=$(date -u +%F)
n=1
while git rev-parse -q --verify "refs/tags/release-$day.$n" >/dev/null; do n=$((n + 1)); done
name="release-$day.$n"
prev=$(git describe --tags --abbrev=0 --match 'release-*' "$sha" 2>/dev/null || true)
range=${prev:+$prev..}$sha
body=$(git log --format='- %s' "$range")
git -c user.name=release-trial -c user.email=release-trial@users.noreply.github.com \
  tag -a "$name" -m "Release $name" -m "$body" "$sha"
git push -q origin "refs/tags/$name"
echo "Tagged $sha as $name."

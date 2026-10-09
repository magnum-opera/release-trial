#!/usr/bin/env bash
# The rule the Pipeline's check and the deployment share.
#
#   scripts/paths.sh kind <base> <head>       derived | revert | code
#   scripts/paths.sh tag <service> <commit>   the commit whose image runs <service> at <commit>
#
# A derived file is one the Orchestrator writes by rule: a changelog, a version
# field, a consumed changeset or the two knowledge-graph files.
set -euo pipefail

EMPTY_TREE=4b825dc642cb6eb9a060e54bf8d69288fbee4904

service_paths() {
  case "$1" in
    api) echo "api" ;;
    web) echo "web" ;;
    *) echo "unknown service: $1" >&2; exit 2 ;;
  esac
}

is_derived() { # <file> <from> <to>
  case "$1" in
    CHANGELOG.md | */CHANGELOG.md | .changeset/*.md | graphify-out/graph.json | graphify-out/GRAPH_REPORT.md) return 0 ;;
    package.json | */package.json)
      # Derived only when every changed line is the version field.
      ! git diff -U0 "$2" "$3" -- "$1" | grep -vE '^(\+\+\+|---) ' | grep -E '^[+-]' \
        | grep -vqE '^[+-][[:space:]]*"version":' ;;
    *) return 1 ;;
  esac
}

derived_only() { # <from> <to> [paths...]: true when something changed and all of it is derived
  local from=$1 to=$2 files f
  shift 2
  files=$(git diff --name-only "$from" "$to" -- "$@")
  [ -n "$files" ] || return 1
  for f in $files; do is_derived "$f" "$from" "$to" || return 1; done
}

kind() { # <base> <head>
  local base=$1 head=$2 mb head_tree c
  mb=$(git merge-base "$base" "$head")
  if derived_only "$mb" "$head"; then echo derived; return; fi
  # An exact revert: the head's tree is one main already had before.
  head_tree=$(git rev-parse "$head^{tree}")
  for c in $(git rev-list --first-parent -n 20 "$base" | tail -n +2); do
    if [ "$(git rev-parse "$c^{tree}")" = "$head_tree" ]; then echo revert; return; fi
  done
  echo code
}

tag() { # <service> <commit>
  local paths c parent
  paths=$(service_paths "$1")
  for c in $(git log --format=%H "$2" -- $paths); do
    parent=$(git rev-parse -q --verify "$c^" || echo "$EMPTY_TREE")
    if ! derived_only "$parent" "$c" $paths; then echo "${c:0:12}"; return; fi
  done
  echo "no commit builds $1 at $2" >&2
  exit 1
}

"$@"

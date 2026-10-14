#!/bin/sh
# Prefer Lefthook if installed; otherwise native git hooks.
set -e
cd "$(dirname "$0")/.."
if command -v lefthook >/dev/null 2>&1; then
  lefthook install
  echo "Lefthook hooks installed."
else
  git config core.hooksPath scripts/githooks
  echo "Git hooksPath → scripts/githooks"
fi
chmod +x scripts/githooks/*

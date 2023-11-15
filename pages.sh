#!/bin/sh

FORGE_DOMAIN="$(echo "$CI_REPO_URL" | cut -d '/' -f 3)"

if ! [ "$FORGE_DOMAIN" = "codeberg.org" ]; then
    exit 0
fi

export SYSTEM_BRANCH="$(basename "$CI_COMMIT_REF")-pages"
if [ "$(basename "$CI_COMMIT_REF")" = "main" ]; then export SYSTEM_BRANCH="pages"; fi
gitio branch GIT_BRANCH:"$SYSTEM_BRANCH"

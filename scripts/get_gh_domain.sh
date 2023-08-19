#!/bin/sh

curl -s "https://api.github.com/repos/$GIT_USERNAME/$GIT_PROJECT_NAME" | jq -r '.homepage' | cut -d "/" -f 3

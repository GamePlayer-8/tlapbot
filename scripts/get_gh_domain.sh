#!/bin/sh

curl -s "https://api.github.com/repos/${{ github.repository_owner }}/${{ github.event.repository.name }}" | jq -r '.homepage' | cut -d "/" -f 3

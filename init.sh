#!/bin/sh

# Run carefully

apk add --no-cache openssl bash
cd /source

echo 'Executing setup...'
sh /source/scripts/set.sh /source/docs/parser.conf /source/index.html
sh /source/scripts/set.sh /source/docs/parser.conf /source/README.md

echo 'Executing certificate launchpad setup...'
sh /source/setup.sh

mkdir -pv /runner/page/
cp -rv /source/* /runner/page/
cp -rv /source/.github /runner/page/

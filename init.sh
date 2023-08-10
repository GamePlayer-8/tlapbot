#!/bin/sh

# Run carefully

apk add --no-cache openssl bash markdown
cd /source

echo '<!DOCTYPE html>' > index.html
echo '<html lang="en-US">' >> index.html
cat docs/head.html >> index.html

echo '<body>' >> index.html
markdown README.md >> index.html
echo '</body>' >> index.html
echo '</html>' >> index.html

echo 'Executing setup...'
sh /source/scripts/set.sh /source/docs/parser.conf /source/index.html
sh /source/scripts/set.sh /source/docs/parser.conf /source/README.md

mkdir -pv /runner/page/
cp -rv /source/* /runner/page/
cp -rv /source/.github /runner/page/

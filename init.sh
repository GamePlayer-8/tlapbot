#!/bin/sh

# Run carefully

apk add --no-cache openssl bash markdown
cd /source

# about.html

echo '<!DOCTYPE html>' > about.html
echo '<html lang="en-US">' >> about.html
cat docs/head.html >> about.html

echo '<body>' >> about.html
echo '<div class="content">' >> about.html
markdown README.md >> about.html
echo '</div>' >> about.html
echo '</body>' >> about.html
echo '</html>' >> about.html

# docs.html

echo '<!DOCTYPE html>' > docs.html
echo '<html lang="en-US">' >> docs.html
cat docs/head.html >> docs.html

echo '<body>' >> docs.html
echo '<div class="content">' >> about.html
markdown resource/README.md >> docs.html
echo '</div>' >> about.html
echo '</body>' >> docs.html
echo '</html>' >> docs.html

echo 'Executing setup...'
sh /source/scripts/set.sh /source/docs/parser.conf /source/about.html
sh /source/scripts/set.sh /source/docs/parser.conf /source/index.html
sh /source/scripts/set.sh /source/docs/parser.conf /source/download.html
sh /source/scripts/set.sh /source/docs/parser.conf /source/docs.html
sh /source/scripts/set.sh /source/docs/parser.conf /source/README.md

mkdir /runner
cp -rv /source /runner/page

#!/bin/sh

apk add --no-cache openssl bash markdown

SCRIPT_PATH="$(dirname "$(realpath "$0")")"
cd "$SCRIPT_PATH"

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
cat docs/head-docs.html >> docs.html

echo '<body>' >> docs.html
echo '<div class="content">' >> docs.html
markdown resource/README.md >> docs.html
echo '</div>' >> docs.html
echo '</body>' >> docs.html
echo '</html>' >> docs.html

echo 'Executing setup...'
sh scripts/set.sh docs/parser.conf about.html
sh scripts/set.sh docs/parser.conf index.html
sh scripts/set.sh docs/parser.conf download.html
sh scripts/set.sh docs/parser.conf docs.html
sh scripts/set.sh docs/parser.conf README.md

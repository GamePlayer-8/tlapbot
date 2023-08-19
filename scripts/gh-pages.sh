#!/bin/bash

git config --global credential.helper store
git config --global user.name "$GIT_USERNAME"
git config --global user.email gameplayer2019pl@tutamail.com
git config --global http.postBuffer 524288000
git config --global init.defaultBranch gh-pages

echo "Checking https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/${GIT_USERNAME}/${GIT_PROJECT_NAME}..."

http_response=$(curl -s -o /dev/null -w "%{http_code}" -u "$GIT_USERNAME:$GIT_TOKEN" -X GET https://api.github.com/repos/"$GIT_USERNAME"/"$GIT_PROJECT_NAME"/branches/gh-pages)

echo 'EXIT CODE '"$http_response"

cd /runner

if [ $http_response -eq 200 ]; then
    git clone -b gh-pages https://$GIT_USERNAME:$GIT_TOKEN@github.com/$GIT_USERNAME/$GIT_PROJECT_NAME gh-pages

    rm -rf page/.git
    mv gh-pages/.git page/

    rm -rf gh-pages
    cd page
else
    cd page
    rm -rf .git
    git init
fi

git branch -m gh-pages
git add -A
git commit -m "Pages synchronization at $(date +%Y-%m-%d)"

git remote remove origin 2>/dev/null 3>&2
git remote add origin https://$GIT_USERNAME:$GIT_TOKEN@github.com/$GIT_USERNAME/$GIT_PROJECT_NAME

echo "Pushing to 'https://github.com/$GIT_USERNAME/$GIT_PROJECT_NAME'..."
echo "https://$GIT_USERNAME:$GIT_TOKEN@github.com" > ~/.git-credentials

git push -f -u origin gh-pages

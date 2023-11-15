#!/bin/sh

apk add --no-cache py-pip linux-headers build-base python3-dev > /dev/null 2>&1 3>&1

pip install --upgrade wheel setuptools > /dev/null 2>&1 3>&1
sh scripts/generate_requirements.sh resource/setup.py requirements.txt
pip install -r requirements.txt > /dev/null 2>&1 3>&1
pip install autopep8 pylint > /dev/null 2>&1 3>&1

mkdir app

cp -r resource/tlapbot/* app/
cp resource/*.py app/
cp resource/*.in app/
cp -r patches/* app/

cd app

if [ -d "../powerpatch" ]; then
    for X in $(find "../powerpatch" -type f); do
        diff -u "$X" "$(basename "$X")" > "../powerpatch/$(basename "$X")".patch
        patch -R -i "../powerpatch/$(basename "$X")".patch "$(basename "$X")"
        rm -f "../powerpatch/$(basename "$X")".patch
    done
fi

for X in $(find . -name '*.py'); do
    echo ">>> CHECKING: $X <<<"
    pylint --disable=F0401 "$X"
    pylint_exit=$?
    if [ $pylint_exit != 0 ]; then
        echo ""
        echo " >>> !<>! <<< "
        echo "Pylint detected errors in $X - please fix them if possible."
    fi
done

echo 'Linting check: Finished!'
exit 0

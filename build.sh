#!/bin/sh

if [ -z "$1" ]; then
    echo 'Missing build type!'
    exit 1
fi

SCRIPT_PATH="$(dirname "$(realpath "$0")")"
APP_NAME="${APP_NAME:-$(basename $SCRIPT_PATH)}"

export ICON="${ICON:-${SCRIPT_PATH}/res/icon.png}"
export BINARY_NAME="$APP_NAME"

cd "${SCRIPT_PATH}"

if ! [ -d "dists" ]; then
    mkdir -p "dists"
fi

sed -i 's|dists/||g' .gitignore

windows() {
    # Build for Windows
    export PLATFORM="windows"
    sh runner/pyinstaller.sh
    mkdir windows
    mv dist/* windows/
    rm -rf dist
    mv windows dists/
}

ubuntu() {
    # Build for Ubuntu
    export PLATFORM="ubuntu"
    sh runner/pyinstaller.sh
    mkdir ubuntu
    mv dist/* ubuntu/
    rm -rf dist
    mv ubuntu dists/
}

alpine() {
    # Build for Alpine
    export PLATFORM="alpine"
    sh runner/pyinstaller.sh
    mkdir alpine
    mv dist/* alpine/
    rm -rf dist
    mv alpine dists/
}

eval "$1"

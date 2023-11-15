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
    rename dist windows
    mv windows dists/
}

ubuntu() {
    # Build for Ubuntu
    export PLATFORM="ubuntu"
    sh runner/pyinstaller.sh
    rename dist ubuntu
    mv ubuntu dists/
}

alpine() {
    # Build for Alpine
    export PLATFORM="alpine"
    sh runner/pyinstaller.sh
    rename dist alpine
    mv alpine dists/
}

eval "$1"

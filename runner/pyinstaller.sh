#!/bin/sh

SCRIPT_PATH="$(dirname "$(realpath "$0")")"
PROJECT_PATH="${PROJECT_PATH:-$SCRIPT_PATH/../app}"
ICON="${ICON:-$PROJECT_PATH/icon.png}"
LAUNCH_SCRIPT="${LAUNCH_SCRIPT:-$PROJECT_PATH/runner.py}"
BINARY_NAME="${BINARY_NAME:-$(basename "$PROJECT_PATH")}"
PLATFORM="${PLATFORM:-'alpine'}"

export TZ="UTC"
export DEBIAN_FRONTEND=noninteractive

if ! [ -d "$PROJECT_PATH" ]; then
    echo 'No app dir found!'
    exit 1
fi

cd "$PROJECT_PATH"

case "$PLATFORM" in
    "alpine")
            apk add --no-cache \
                apk-tools-static py-pip py-pip bash linux-headers \
                build-base python3-dev xvfb appstream \
                tar libc6-compat curl upx gawk sed gcompat > /dev/null

            pip install --break-system-packages pipx

            GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc
            GLIBC_VERSION="${GLIBC_VERSION:-2.35-r1}"

            for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION}; \
                do curl -sSL \
                    ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk \
                    -o /tmp/${pkg}.apk
            done

            apk add --allow-untrusted --no-cache -f /tmp/*.apk > /dev/null
            /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib

            rm -rf /tmp/*.apk
            ;;
    "ubuntu")
            apt update > /dev/null
            apt install --yes \
                python3-pip \
                linux-headers-generic build-essential \
                bash python3-dev sed xvfb appstream tar \
                lsb-release apt-utils file curl upx gawk > /dev/null
            
            pip install pipx
            ;;
    "windows")
            apt update > /dev/null
            apt install --yes \
                wine apt-utils sed tar curl \
                xvfb winetricks bash gawk > /dev/null
            dpkg --add-architecture i386
            apt-get update > /dev/null
            apt-get install --yes wine32 > /dev/null
            ;;
    *)
            echo "Unsupported PLATFORM."
            exit 4
            ;;
esac

export ARCH="${ARCH:-$(uname -m)}"
export PATH="$HOME/.local/bin:$PATH"


if [ -z $DISPLAY ]; then
    Xvfb -ac :3 -screen 0 1280x1024x24 &
    export DISPLAY_PID=$!
    export DISPLAY=":3"
fi

case "$PLATFORM" in
    "alpine")
            pip install --break-system-packages --upgrade setuptools wheel > /dev/null
            ;;
    "ubuntu")
            pip install --upgrade setuptools wheel > /dev/null
            ;;
esac

if [ -f "setup.py" ]; then
    # Extract the list of dependencies using awk
    list=$(awk -F"'" '/install_requires=/,/\]/ {if ($0~/^[ \t]*'\''.*'\'',?$/) print $2}' setup.py)

    # Loop through each element and write to requirements.txt
    echo "$list" | while IFS= read -r element; do
        echo "$element" >> requirements.txt
    done
fi
if [ "$PLATFORM" = "windows" ]; then
    sed -i 's/gunicorn/waitress/g' requirements.txt # Remove gunicorn due to missing fnctl for Windows
fi

case "$PLATFORM" in
    "alpine")
            pip install --break-system-packages -r requirements.txt > /dev/null
            pip install --break-system-packages pyinstaller > /dev/null
            ;;
    "ubuntu")
            pip install -r requirements.txt > /dev/null
            pip install pyinstaller > /dev/null
            ;;
esac

python_version() {
    local url='https://www.python.org/ftp/python/'

    curl -s "$url" |
        sed -n 's!.*href="\([0-9]\+\.[0-9]\+\.[0-9]\+\)/".*!\1!p' |
        sort -rV |
    while read -r version; do
        filename="Python-$version.tar.xz"
        # Versions which only have alpha, beta, or rc releases will fail here.
        # Stop when we find one with a final release.
        if curl --fail --silent -O "$url/$version/$filename"; then
            echo "$version"
            break
        fi
    done
}

upx_version() {
    local url='https://api.github.com/repos/upx/upx/releases/latest'

    curl -s "$url" |
    grep -i "\"tag_name\"" |
    cut -d '"' -f 4
}

if [ "$PLATFORM" = "windows" ]; then
    export WINEPREFIX=/tmp/wine
    export WINEDEBUG="-all"
    export PYTHON_VERSION=$(python_version)
    export UPX_VERSION=$(upx_version)
    export WINEDLLOVERRIDES="winemenubuilder.exe,mscoree,mshtml="
fi

py_deps=""
for X in $(cat requirements.txt); do
    py_deps=$py_deps' --collect-all '$X
done

for X in $(find . -name '__pycache__'); do
    rm -rf "$X"
done

if [ -d "../powerpatch" ]; then
    for X in $(find "../powerpatch" -type f); do
        diff -u "$X" "$(basename "$X")" > "../powerpatch/$(basename "$X")".patch
        patch -R -i "../powerpatch/$(basename "$X")".patch "$(basename "$X")"
        rm -f "../powerpatch/$(basename "$X")".patch
    done
fi

py_data=""
for X in .; do
    if [ -f "$X" ]; then
        BASENAME=$(basename "$X")
        py_data=$py_data" --add-data $BASENAME:."
    fi
done

py_dirs=""
for X in .; do
    if [ -d "$X" ]; then
        BASENAME=$(basename "$X")
        py_dirs=$py_dirs" --add-data $BASENAME/*:$BASENAME/"
    fi
done

if ! [ "$PLATFORM" = "windows" ]; then
    if [ -f "setup.py" ]; then
        python3 setup.py build
        python3 setup.py install
    fi

    pyinstaller -F --onefile --windowed \
    --additional-hooks-dir=. $py_dirs $py_data \
    $py_deps -i "$ICON" -n "$BINARY_NAME" -c "$LAUNCH_SCRIPT"

else
    xvfb-run sh -c "wine reg add 'HKLM\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentVersion /d 10.0 /f && \
    wine reg add 'HKCU\Software\Wine\DllOverrides' /v winemenubuilder.exe /t REG_SZ /d '' /f && \
    wine reg add 'HKCU\Software\Wine\DllOverrides' /v mscoree /t REG_SZ /d '' /f && \
    wine reg add 'HKCU\Software\Wine\DllOverrides' /v mshtml /t REG_SZ /d '' /f; \
    wineserver -w"

    curl -s https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe -o /tmp/python-${PYTHON_VERSION}-amd64.exe
    curl -s https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-win64.zip -o /tmp/upx-${UPX_VERSION}-win64.zip

    xvfb-run sh -c "\
        wine /tmp/python-${PYTHON_VERSION}-amd64.exe /quiet TargetDir=C:\\Python310 \
        Include_doc=0 InstallAllUsers=1 PrependPath=1; \
        wineserver -w"
    
    cd /tmp/

    unzip -o upx*.zip && \
    mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/

    rm -rf upx* python*.exe

    cd "$PROJECT_PATH"

    export WINEPATH='C:\Python310\Scripts'

    wine python -m pip install --upgrade setuptools wheel pip
    wine python -m pip install pyinstaller
    wine python -m pip install -r requirements.txt
    if [ -f "setup.py" ]; then
        wine python setup.py build
        wine python setup.py install
    fi

    if ! [ "${ICON##*.}" = "ico" ]; then
        apt install --yes imagemagick
        convert -resize x16 \
            -gravity center \
            -crop 16x16+0+0 "${ICON}" \
            -flatten -colors 256 \
            -background transparent "${ICON}.ico"

        wine pyinstaller $py_deps_tlapbot $py_dirs_tlapbot $py_data_tlapbot \
            -F --onefile --windowed \
            --additional-hooks-dir=. \
            -i "${ICON}.ico" -n "$BINARY_NAME" -c "$LAUNCH_SCRIPT"
        
        rm -f "${ICON}.ico"
    else
        wine pyinstaller $py_deps_tlapbot $py_dirs_tlapbot $py_data_tlapbot \
            -F --onefile --windowed \
            --additional-hooks-dir=. \
            -i "$ICON" -n "$BINARY_NAME" -c "$LAUNCH_SCRIPT"
    fi

    OLD_BINARY_NAME="$BINARY_NAME"
    BINARY_NAME="${BINARY_NAME}.exe"
    sed -i 's/waitress/gunicorn/g' requirements.txt
fi

mv "dist/$BINARY_NAME" "../$BINARY_NAME"
rm -rf dist build log

cd ..

strip "$BINARY_NAME"
chmod +x "$BINARY_NAME"

if ! [ "$PLATFORM" = "windows" ]; then
    case "$PLATFORM" in
        "alpine")
                /sbin/apk.static \
                    -X https://dl-cdn.alpinelinux.org/alpine/latest-stable/main \
                    -U --allow-untrusted -p "/tmp/${BINARY_NAME}.AppDir/" \
                    --initdb add --no-cache alpine-base busybox libc6-compat
                ;;
        "ubuntu")
                mkdir -p "/tmp/${BINARY_NAME}.AppDir/var/lib/dpkg"
                mkdir -p "/tmp/${BINARY_NAME}.AppDir/var/cache/apt/archives"
                apt install --yes debootstrap fakeroot fakechroot
                DEBIAN_STRAP_ARCH="amd64"
                case "$ARCH" in
                        "x86_64")
                            DEBIAN_STRAP_ARCH="amd64"
                            ;;
                        "x86"|"i386"|"i686")
                            DEBIAN_STRAP_ARCH="i386"
                            ;;
                        "aarch64"|"aarch64_be"|"armv8b"|"armv8l")
                            DEBIAN_STRAP_ARCH="aarch64"
                            ;;
                        "arm")
                            DEBIAN_STRAP_ARCH="arm"
                            ;;
                        "riscv64")
                            DEBIAN_STRAP_ARCH="riscv64"
                            ;;
                esac

                fakechroot fakeroot debootstrap \
                    --variant=fakechroot \
                    --arch "${DEBIAN_STRAP_ARCH}" 22.04 \
                    "/tmp/${BINARY_NAME}.AppDir/" \
                    http://archive.ubuntu.com/ubuntu > /dev/null
                ;;
    esac

    cp "$ICON" "/tmp/${BINARY_NAME}.AppDir/icon.png"

    echo '[Desktop Entry]' > "/tmp/${BINARY_NAME}.AppDir/${BINARY_NAME}.desktop"
    echo 'Name='"${BINARY_NAME}" >> "/tmp/${BINARY_NAME}.AppDir/${BINARY_NAME}.desktop"
    echo 'Categories=Settings' >> "/tmp/${BINARY_NAME}.AppDir/${BINARY_NAME}.desktop"
    echo 'Type=Application' >> "/tmp/${BINARY_NAME}.AppDir/${BINARY_NAME}.desktop"
    echo 'Icon=icon' >> "/tmp/${BINARY_NAME}.AppDir/${BINARY_NAME}.desktop"
    echo 'Terminal=true' >> "/tmp/${BINARY_NAME}.AppDir/${BINARY_NAME}.desktop"
    if [ "$PLATFORM" = "alpine" ]; then
        echo 'Exec=/lib/ld-musl-x86_64.so.1 /usr/bin/'"${BINARY_NAME}" >> "/tmp/${BINARY_NAME}.AppDir/${BINARY_NAME}.desktop"
    else
        echo 'Exec=/lib/ld-linux-x86-64.so.2 /usr/bin/'"${BINARY_NAME}" >> "/tmp/${BINARY_NAME}.AppDir/${BINARY_NAME}.desktop"
    fi

    chmod +x "/tmp/${BINARY_NAME}.AppDir/${BINARY_NAME}.desktop"

    echo '#!/bin/sh' > "/tmp/${BINARY_NAME}.AppDir/AppRun"
    echo 'APP_RUNPATH="$(dirname "$(readlink -f "${0}")")"' >> "/tmp/${BINARY_NAME}.AppDir/AppRun"
    echo 'APP_EXEC="${APP_RUNPATH}"/usr/bin/'"${BINARY_NAME}" >> "/tmp/${BINARY_NAME}.AppDir/AppRun"
    echo 'export LD_LIBRARY_PATH="${APP_RUNPATH}"/lib:"${APP_RUNPATH}"/lib64:$LD_LIBRARY_PATH' >> "/tmp/${BINARY_NAME}.AppDir/AppRun"
    echo 'export LIBRARY_PATH="${APP_RUNPATH}"/lib:"${APP_RUNPATH}"/lib64:"${APP_RUNPATH}"/usr/lib:"${APP_RUNPATH}"/usr/lib64:$LIBRARY_PATH' >> "/tmp/${BINARY_NAME}.AppDir/AppRun"
    echo 'export PATH="${APP_RUNPATH}/usr/bin/:${APP_RUNPATH}/usr/sbin/:${APP_RUNPATH}/usr/games/:${APP_RUNPATH}/bin/:${APP_RUNPATH}/sbin/${PATH:+:$PATH}"' >> "/tmp/${BINARY_NAME}.AppDir/AppRun"
    if [ "$PLATFORM" = "alpine" ]; then
        echo 'exec "${APP_RUNPATH}"/lib/ld-musl-x86_64.so.1 "${APP_EXEC}" "$@"' >> "/tmp/${BINARY_NAME}.AppDir/AppRun"
    else
        echo 'exec "${APP_RUNPATH}"/lib/ld-linux-x86-64.so.2 "${APP_EXEC}" "$@"' >> "/tmp/${BINARY_NAME}.AppDir/AppRun"
    fi

    chmod +x "/tmp/${BINARY_NAME}.AppDir/AppRun"

    mkdir -p "/tmp/${BINARY_NAME}.AppDir/usr/bin"
    cp "$BINARY_NAME" "/tmp/${BINARY_NAME}.AppDir/usr/bin/${BINARY_NAME}"
    chmod +x "/tmp/${BINARY_NAME}.AppDir/usr/bin/${BINARY_NAME}"

    cd /tmp/
    curl -LO https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage
    chmod +x appimagetool-x86_64.AppImage
    ./appimagetool-x86_64.AppImage --appimage-extract
    rm -f appimagetool-x86_64.AppImage
    mv squashfs-root appimagetool.AppDir
    ln -s /tmp/appimagetool.AppDir/AppRun /usr/local/bin/appimagetool
    chmod +x /opt/appimagetool.AppDir/AppRun

    appimagetool "/tmp/${BINARY_NAME}.AppDir/"

    rm -f /usr/local/bin/appimagetool

    rm -rf "/tmp/${BINARY_NAME}.AppDir"
    rm -rf /tmp/appimagetool.AppDir

    mv "${BINARY_NAME}"-"${ARCH}".AppImage "${BINARY_NAME}".AppImage
    chmod +x "${BINARY_NAME}".AppImage
fi

rm -rf "$PROJECT_PATH/../dist"
if [ "$PLATFORM" = "windows" ]; then
    rm -f "$PROJECT_PATH/${OLD_BINARY_NAME}.spec"
else
    rm -f "$PROJECT_PATH/${BINARY_NAME}.spec"
fi
mkdir "$PROJECT_PATH/../dist"

if ! [ "$PLATFORM" = "windows" ]; then
    mv "${BINARY_NAME}.AppImage" "$PROJECT_PATH/../dist/"
fi
mv "$PROJECT_PATH/../${BINARY_NAME}" "$PROJECT_PATH/../dist/"

if ! [ -z $DISPLAY_PID ]; then
    kill -9 $DISPLAY_PID
    unset DISPLAY_PID
fi

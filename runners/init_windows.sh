#!/bin/sh

export TZ="Europe/Warsaw"
export DEBIAN_FRONTEND=noninteractive

apt update > /dev/null
cd /source

apt install --yes wine apt-utils tar wget xvfb winetricks > /dev/null
dpkg --add-architecture i386 && apt-get update > /dev/null && apt-get install --yes wine32 > /dev/null

sed -i 's/gunicorn/waitress/g' requirements.txt # Remove gunicorn due to missing fnctl for Windows

py_deps_tlapbot=""
for X in $(cat requirements.txt); do
    py_deps_tlapbot=$py_deps_tlapbot' --collect-all '$X
done

for X in $(find . -name '__pycache__'); do
    rm -rf "$X"
done

cp /source/patches/* /source/resource/tlapbot/

py_data_tlapbot=""
for X in ./resource/tlapbot/*; do
    if [ -f "$X" ]; then
        BASENAME=$(basename "$X")
        py_data_tlapbot=$py_data_tlapbot" --add-data $BASENAME;."
    fi
done

py_dirs_tlapbot=""
for X in ./resource/tlapbot/*; do
    if [ -d "$X" ]; then
        BASENAME=$(basename "$X")
        py_dirs_tlapbot=$py_dirs_tlapbot" --add-data $BASENAME/*;$BASENAME/"
    fi
done

export WINEPREFIX=/wine
export DISPLAY=":0"
export WINEDEBUG="-all"
export PYTHON_VERSION=3.11.3
export UPX_VERSION=3.96
export WINEDLLOVERRIDES="winemenubuilder.exe,mscoree,mshtml="

Xvfb -ac :0 -screen 0 1280x1024x24 &
sleep 5

xvfb-run sh -c "wine reg add 'HKLM\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentVersion /d 10.0 /f && \
wine reg add 'HKCU\Software\Wine\DllOverrides' /v winemenubuilder.exe /t REG_SZ /d '' /f && \
wine reg add 'HKCU\Software\Wine\DllOverrides' /v mscoree /t REG_SZ /d '' /f && \
wine reg add 'HKCU\Software\Wine\DllOverrides' /v mshtml /t REG_SZ /d '' /f; \
wineserver -w"

wget -q https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe -O /python-${PYTHON_VERSION}-amd64.exe
wget -q https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-win64.zip -O /upx-${UPX_VERSION}-win64.zip

cd /

xvfb-run sh -c "\
    wine /python-${PYTHON_VERSION}-amd64.exe /quiet TargetDir=C:\\Python310 \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w" && \
  unzip -o upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/

export WINEPATH='C:\Python310\Scripts'

wine python -m pip install --upgrade setuptools wheel pip
wine python -m pip install pyinstaller

cd /source

sh scripts/generate_requirements.sh resource/setup.py requirements.txt
wine python -m pip install -r requirements.txt


cd resource
wine python setup.py build
wine python setup.py install
rm -rf tlapbot.egg-info

cd tlapbot

wine pyinstaller $py_deps_tlapbot $py_dirs_tlapbot $py_data_tlapbot \
  -F --onefile --console \
  --additional-hooks-dir=. \
  -i '../../docs/icon.ico' -n tlapbot -c standalone.py

mv dist/tlapbot.exe ../..
rm -rf dist build log

cd ../..

sed -i 's/waitress/gunicorn/g' requirements.txt

chmod +x tlapbot.exe

mkdir -pv /runner/page/
cp -rv /source/* /runner/page/

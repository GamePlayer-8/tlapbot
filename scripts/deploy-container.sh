#!/bin/sh

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

if [ -z "$1" ]; then
    echo "Missing the pull image!"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Missing the output image name!"
    exit 2
fi

if [ -z "$3" ]; then
    echo "Missing Dockerfile path!"
    exit 3
fi

cd /source

apk add --no-cache podman fuse-overlayfs gawk tar gzip

cp pipeline/containers.conf /etc/containers/containers.conf
chmod 644 /etc/containers/containers.conf && \
    sed -i -e 's|^#mount_program|mount_program|g' -e \
    '/additionalimage.*/a "/var/lib/shared",' -e \
    's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
    /etc/containers/storage.conf && \
    mkdir -p /var/lib/shared/overlay-images \
    /var/lib/shared/overlay-layers /var/lib/shared/vfs-images \
    /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock && \
    mkdir /listen

export _CONTAINERS_USERNS_CONFIGURED=""

podman system migrate

podman pull "$1"

cd "$3"

podman build -t "$REGISTRY_USER"/"$2" .

export REGISTRY_DOMAIN=$(echo "$REGISTRY_DOMAIN" | awk '{print tolower($0)}')
export REGISTRY_USER=$(echo "$REGISTRY_USER" | awk '{print tolower($0)}')

echo "$REGISTRY_TOKEN" | podman login "$REGISTRY_DOMAIN" -u "$REGISTRY_USER" --password-stdin

podman tag "$REGISTRY_USER"/"$2" "$REGISTRY_DOMAIN"/"$REGISTRY_USER"/"$2"

podman push "$REGISTRY_DOMAIN"/"$REGISTRY_USER"/"$2"

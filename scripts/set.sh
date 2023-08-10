#!/bin/sh

if [ -z "$1" ]; then
    echo 'Missing parser!'
    exit 1
fi

if [ -z "$2" ]; then
    echo 'Missing target!'
    exit 2
fi

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

while IFS= read -r line; do
    if [[ -n "$line" && ! "$line" =~ ^#.* ]]; then
        param_name=$(echo "$line" | cut -d "=" -f 1)
        param_value=$(echo "$line" | cut -d "=" -f 2)

        cmd_value=$(echo "$param_value" | cut -d " " -f 1)

        case "$cmd_value" in
            "@datimize")
                param_value="$(sh "$SCRIPT_PATH"/datimize.sh $(echo "$param_value" | cut -d " " -f 2))"
                ;;
            "@env")
                param_value="$(sh "$SCRIPT_PATH"/env.sh $(echo "$param_value" | cut -d " " -f 2))"
                ;;
        esac

        echo 'Installing '"$param_name"' with config `'"$param_value"'`...'

        sed -i "s|${param_name}|${param_value}|g" "$2"
    fi
done < "$1"

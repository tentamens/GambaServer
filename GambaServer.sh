#!/bin/sh
echo -ne '\033c\033]0;GambaServer\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/GambaServer.x86_64" "$@"

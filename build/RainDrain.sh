#!/bin/sh
echo -ne '\033c\033]0;RainDrain\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/RainDrain.x86_64" "$@"

#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT

export HOME="$temporary/home"
export XDG_CONFIG_HOME="$temporary/config"
export XDG_DATA_HOME="$temporary/data"
export XDG_CACHE_HOME="$temporary/cache"
export ROON_PROTON_LIB_ONLY=1

# shellcheck source=../roon-wine
source "$root/roon-wine"

application="$XDG_DATA_HOME/roon-wine/prefix/drive_c/users/steamuser/AppData/Local/Roon/Application"
mkdir -p "$application/207001671" "$application/207101683"
touch "$application/207001671/Roon.exe"
touch "$application/207101683/Roon.exe"

expected="$application/207101683/Roon.exe"
actual=$(find_roon)
[[ $actual == "$expected" ]] || {
  printf 'expected newest numbered build %s, got %s\n' "$expected" "$actual" >&2
  exit 1
}

touch "$application/Roon.exe"
expected="$application/Roon.exe"
actual=$(find_roon)
[[ $actual == "$expected" ]] || {
  printf 'expected unversioned fallback %s, got %s\n' "$expected" "$actual" >&2
  exit 1
}

payload="$application/207101683"
printf 'prefixRoon.dll' > "$payload/Roon.exe"
head -c 80 /dev/zero >> "$payload/Roon.exe"
printf 'prefixRAATServer.dll' > "$payload/RAATServer.exe"
head -c 80 /dev/zero >> "$payload/RAATServer.exe"
printf '<probing privatePath="207101683"/>\n' > "$payload/Roon.exe.config"
cp "$payload/Roon.exe.config" "$payload/RAATServer.exe.config"
printf '207101683\n2.71 (build 1683) production\nproduction\n' > "$payload/VERSION"

activate_proton_payload "$payload" "$application" 207101683
rg -a -q -F '207101683\Roon.dll' "$application/Roon.exe"
rg -a -q -F '207101683\RAATServer.dll' "$application/RAATServer.exe"
cmp -s "$payload/Roon.exe.config" "$application/Roon.exe.config"
cmp -s "$payload/RAATServer.exe.config" "$application/RAATServer.exe.config"
cmp -s "$payload/VERSION" "$application/VERSION"

printf 'Roon version selection passed\n'

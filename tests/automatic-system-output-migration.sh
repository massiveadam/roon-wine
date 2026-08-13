#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT

export HOME="$temporary/home"
export XDG_CONFIG_HOME="$temporary/config"
export XDG_DATA_HOME="$temporary/data"
export XDG_CACHE_HOME="$temporary/cache"
export DISPLAY=:1
export ROON_PROTON_LIB_ONLY=1

# shellcheck source=../roon-wine
source "$root/roon-wine"

calls="$temporary/calls"
legacy_link="$HOME/.config/systemd/user/default.target.wants/roon-system-output.service"
mkdir -p "$(dirname "$legacy_link")"
ln -s /usr/lib/systemd/user/roon-system-output.service "$legacy_link"

find_roon() { printf '/tmp/Roon.exe\n'; }
selected_display() { printf 'x11\n'; }
require_display() { :; }
endpoint_command() {
  printf 'migrate %s %s\n' "$1" "$2" >> "$calls"
  rm -f -- "$legacy_link"
}
proton_cmd() { printf 'launch %s %s\n' "$1" "$2" >> "$calls"; }

run_roon >/dev/null
actual=$(paste -sd '|' "$calls")
expected='migrate mode system|launch /tmp/Roon.exe -scalefactor=1.0'
[[ $actual == "$expected" ]] || {
  printf 'legacy launch did not migrate before starting Roon:\n%s\n' "$actual" >&2
  exit 1
}

: > "$calls"
run_roon >/dev/null
actual=$(paste -sd '|' "$calls")
expected='launch /tmp/Roon.exe -scalefactor=1.0'
[[ $actual == "$expected" ]] || {
  printf 'clean launch repeated the migration:\n%s\n' "$actual" >&2
  exit 1
}

ln -s /usr/lib/systemd/user/roon-system-output.service "$legacy_link"
: > "$calls"
endpoint_command() {
  printf 'migration-failed\n' >> "$calls"
  return 1
}
run_roon >/dev/null 2>&1
actual=$(paste -sd '|' "$calls")
expected='migration-failed|launch /tmp/Roon.exe -scalefactor=1.0'
[[ $actual == "$expected" ]] || {
  printf 'failed migration prevented the controller launch:\n%s\n' "$actual" >&2
  exit 1
}
[[ -L $legacy_link ]] || {
  printf 'failed migration consumed its retry marker\n' >&2
  exit 1
}

printf 'automatic System Output migration passed\n'

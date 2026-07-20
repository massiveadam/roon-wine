#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT
mkdir -p "$temporary/home/.config/systemd/user"
touch "$temporary/home/.config/systemd/user/roonbridge-native.service"

export HOME="$temporary/home"
export XDG_CONFIG_HOME="$temporary/config"
export XDG_DATA_HOME="$temporary/data"
export XDG_CACHE_HOME="$temporary/cache"
export ROON_PROTON_LIB_ONLY=1

# shellcheck source=../roon-wine
source "$root/roon-wine"

calls="$temporary/calls"
require_systemd_user() { :; }
require_system_output() { :; }
ensure_loopback_capture() { :; }
stop_managed_prefix() { printf 'stop-prefix\n' >> "$calls"; }
systemctl() { printf 'systemctl %s\n' "$*" >> "$calls"; }

assert_order() {
  local mode=$1 expected=$2 actual
  : > "$calls"
  endpoint_command mode "$mode" >/dev/null
  actual=$(paste -sd '|' "$calls")
  [[ $actual == "$expected" ]] || {
    printf '%s mode used the wrong transition order:\n%s\n' "$mode" "$actual" >&2
    return 1
  }
}

assert_order system \
  'systemctl --user stop roonbridge-native.service|stop-prefix|systemctl --user enable --now roon-system-output.service roonbridge-native.service'
assert_order direct \
  'systemctl --user disable --now roon-system-output.service|systemctl --user stop roonbridge-native.service|stop-prefix|systemctl --user enable --now roonbridge-native.service'

printf 'endpoint mode ordering passed\n'

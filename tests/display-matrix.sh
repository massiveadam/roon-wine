#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT
mkdir -p "$temporary/home"

check_display() {
  local name=$1 session=$2 wayland=$3 x11=$4 configured=$5 expected=$6 availability=$7
  local config_home="$temporary/$name-config" output
  mkdir -p "$config_home/roon-wine"
  printf 'display=%s\naudio=pulse\nscale=1.0\nrunner=proton\n' "$configured" \
    > "$config_home/roon-wine/config"
  output=$(env -i PATH="$PATH" HOME="$temporary/home" XDG_CONFIG_HOME="$config_home" \
    XDG_DATA_HOME="$temporary/$name-data" XDG_CACHE_HOME="$temporary/$name-cache" \
    XDG_SESSION_TYPE="$session" WAYLAND_DISPLAY="$wayland" DISPLAY="$x11" \
    bash "$root/roon-wine" doctor 2>&1 || true)
  grep -Eq "configured display +$configured -> $expected$" <<< "$output" || {
    printf 'display test %s selected the wrong backend:\n%s\n' "$name" "$output" >&2
    return 1
  }
  if [[ $availability == unavailable ]]; then
    grep -q 'selected display backend is unavailable' <<< "$output" || {
      printf 'display test %s did not report its missing display:\n%s\n' "$name" "$output" >&2
      return 1
    }
  else
    ! grep -q 'selected display backend is unavailable' <<< "$output" || {
      printf 'display test %s incorrectly rejected its display:\n%s\n' "$name" "$output" >&2
      return 1
    }
  fi
}

check_display wayland-auto wayland wayland-1 :1 auto xwayland available
check_display wayland-no-xwayland wayland wayland-1 '' auto xwayland unavailable
check_display x11-auto x11 '' :0 auto x11 available
check_display unknown-session '' '' :0 auto x11 available
check_display forced-wayland wayland wayland-1 '' wayland wayland available
check_display forced-x11 wayland wayland-1 :1 x11 x11 available

printf 'display matrix passed\n'

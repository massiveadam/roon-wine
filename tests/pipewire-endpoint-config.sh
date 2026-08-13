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

settings="$XDG_DATA_HOME/roon-wine/native-endpoint/data/RAATServer/Settings"
device="$settings/device_1f0f577309ce6a7b7b88e9190e81c404.json"
decoy="$settings/device_00000000000000000000000000000000.json"
mkdir -p "$settings"
printf '%s\n' '{"unique_id":"custom-id","output":{"device":"plug:pipewire","type":"alsa","name":"Custom PipeWire Device"},"volume":{"type":"software"},"external_config":{}}' > "$decoy"
printf '%s\n' '{"unique_id":"endpoint-id","output":{"device":"hw:CARD=Loopback,DEV=0","type":"alsa","name":"Loopback  PCM","dsd_mode":"native"},"volume":{"device":"hw:CARD=Loopback,DEV=0","type":"alsa"},"external_config":{}}' > "$device"

configure_pipewire_endpoint

python - "$device" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    config = json.load(handle)

assert config["unique_id"] == "endpoint-id"
assert config["output"] == {
    "device": "plug:pipewire",
    "type": "alsa",
    "name": "System Output (PipeWire)",
    "dsd_mode": "none",
}
assert config["volume"] == {"type": "software"}
assert config["external_config"] == {}
PY

python - "$decoy" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    config = json.load(handle)

assert config["unique_id"] == "custom-id"
assert config["output"]["name"] == "Custom PipeWire Device"
PY

printf 'PipeWire endpoint configuration passed\n'

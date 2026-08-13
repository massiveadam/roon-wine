#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
data_home=${XDG_DATA_HOME:-$HOME/.local/share}
settings="$data_home/roon-wine/native-endpoint/data/RAATServer/Settings"
log="$data_home/roon-wine/native-endpoint/data/RAATServer/Logs/RAATServer_log.txt"

doctor=$(bash "$root/roon-wine" doctor)
grep -q 'endpoint mode.*System Output via shared PipeWire device' <<< "$doctor"
systemctl --user is-active --quiet roonbridge-native.service
! systemctl --user is-active --quiet roon-system-output.service
ss -lntp | grep -E ':9200 .*mono-sgen' >/dev/null

python - "$settings" <<'PY'
import json
from pathlib import Path
import sys

matches = []
for path in Path(sys.argv[1]).glob("device_*.json"):
    try:
        config = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        continue
    if config.get("output", {}).get("name") == "System Output (PipeWire)":
        matches.append(config)

assert len(matches) == 1
assert matches[0]["output"]["device"] == "plug:pipewire"
assert matches[0]["volume"] == {"type": "software"}
PY

grep -q 'output info.*plug:pipewire' "$log"

printf '%s\n' "$doctor"
printf 'Roon Proton System Output doctor passed\n'

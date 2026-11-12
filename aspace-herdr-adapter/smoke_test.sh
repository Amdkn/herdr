#!/usr/bin/env bash
# Smoke test adapter herdr — D-N053 pas F1 (H-F1-3).
# Builds the debug `herdr` binary, checks the CLI-contract surface, and
# verifies the forced switches ([update] version_check=false +
# manifest_check=false) with the binary's own `config check` against the
# embedded adapter config. Never launches a herdr server, never touches
# the machine's real config (HERDR_CONFIG_PATH points at a scratch copy).
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH="$HOME/.cargo/bin:$HOME/workspace/.tmp/zig-x86_64-linux-0.16.0:$PATH"

SCRATCH="$(mktemp -d /var/tmp/aspace-herdr-smoke-XXXXXX)"
trap 'rm -rf "$SCRATCH"' EXIT
cp aspace-herdr-adapter/config.toml "$SCRATCH/config.toml"
export HERDR_CONFIG_PATH="$SCRATCH/config.toml"

cargo build --locked --bin herdr
HERDR="target/debug/herdr"

# CLI-contract surface: version + help + server help (no server contacted).
"$HERDR" --version | grep -q "0.9.5"
"$HERDR" --help | grep -qi "server"
"$HERDR" server --help | grep -qi "stop"

# Forced switches, verified by the binary itself on the embedded config.
"$HERDR" config check | grep -q "config: ok"
grep -q "^version_check = false" "$SCRATCH/config.toml"
grep -q "^manifest_check = false" "$SCRATCH/config.toml"

# Contract surface: self-update and plugin update are NOT in the adapter
# surface (the upstream binary still ships them; the adapter excludes them
# contractually — H-F1-6, "absent ... de la surface").
python3 - <<'EOF'
import json
c = json.load(open("aspace-herdr-adapter/contract.json"))
surface = c["cli"]["surface"]
for banned in ("herdr update", "herdr plugin update"):
    assert banned not in surface, f"{banned} must not be in the adapter surface"
assert c["switches_forced"] == {"manifest_check": False, "version_check": False}
print("contract OK: surface excludes update + plugin update, version_check=false, manifest_check=false")
EOF

echo "smoke herdr OK — version 0.9.5, --help, server --help, config check ok, switches forced"

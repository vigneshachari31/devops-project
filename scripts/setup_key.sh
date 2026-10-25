#!/usr/bin/env bash
# Run as vignesh, not root. This never prints private key material.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
if (( EUID == 0 )); then
  echo "FAIL: run key setup as your normal Ubuntu user." >&2
  exit 1
fi
umask 077
mkdir -p .secrets files
chmod 700 .secrets
private=.secrets/group34_ed25519
public=files/devops.pub
if [[ -e "$private" || -e "$public" ]]; then
  if [[ -f "$private" && -f "$public" ]]; then
    chmod 600 "$private"
    ssh-keygen -l -f "$public"
    echo "Existing files retained; no keys overwritten."
    exit 0
  fi
  echo "FAIL: only one key file exists. Inspect the pair; nothing was overwritten." >&2
  exit 1
fi
# Empty passphrase is only for this disposable local college demonstration.
ssh-keygen -q -t ed25519 -N '' -C group34-local-demo -f "$private"
cp -- "$private.pub" "$public"
chmod 644 "$public"
echo "Created a dedicated demo key; private key stays in .secrets/."
ssh-keygen -l -f "$public"

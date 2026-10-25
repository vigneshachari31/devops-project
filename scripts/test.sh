#!/usr/bin/env bash
# Run as the normal user after sudo authentication, or from an approved WSL root session.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
mkdir -p results
export ANSIBLE_NOCOLOR=1
export ANSIBLE_CONFIG="$PWD/ansible.cfg"
date -u '+%Y-%m-%dT%H:%M:%SZ' > results/executed_at_utc.txt
ansible --version | tee results/environment.txt
ansible-galaxy collection list ansible.posix | tee -a results/environment.txt
ansible-config dump --only-changed | tee results/config.txt
ansible-inventory --graph | tee results/inventory.txt
ansible-playbook secure_server.yml --syntax-check | tee results/syntax.txt
bash -n scripts/setup_key.sh scripts/verify.sh scripts/test.sh
# Obtain credentials before the noninteractive playbook runs. Never record a password.
if (( EUID != 0 )); then sudo -v; fi
ansible-playbook secure_server.yml | tee results/first_run.txt
ansible-playbook secure_server.yml | tee results/second_run.txt
python3 - <<'PY' | tee results/idempotency.txt
from pathlib import Path
import re
for filename in ("first_run.txt", "second_run.txt"):
    output = Path("results", filename).read_text()
    recap = re.search(r"^localhost\s+:\s+ok=(\d+)\s+changed=(\d+)\s+unreachable=(\d+)\s+failed=(\d+)\s+skipped=(\d+)\s+rescued=(\d+)\s+ignored=(\d+)", output, re.M)
    if recap is None:
        raise SystemExit(f"FAIL: Missing recap in {filename}")
    ok, changed, unreachable, failed, skipped, rescued, ignored = map(int, recap.groups())
    if ok == 0 or any((unreachable, failed, rescued, ignored)):
        raise SystemExit(f"FAIL: Unsuccessful execution in {filename}")
    if filename == "second_run.txt" and changed:
        raise SystemExit(f"FAIL: Second run changed {changed} tasks")
    print(f"PASS: {filename}: {recap.group(0).strip()}")
print("PASS: Second execution made zero changes.")
PY
if (( EUID == 0 )); then
  bash scripts/verify.sh | tee results/verification.txt
else
  sudo bash scripts/verify.sh | tee results/verification.txt
fi
echo "All project tests passed. Evidence is in results/."

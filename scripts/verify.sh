#!/usr/bin/env bash
# Read-only checks; use sudo because the demonstration home is private.
set -euo pipefail
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }
[[ $# -le 3 ]] || fail "Usage: verify.sh [user] [group] [public-key-file]"
demo_user=${1:-devopsuser}
demo_group=${2:-devops}
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
public_key=${3:-"$project_dir/files/devops.pub"}
[[ "$demo_user" =~ ^[a-z][a-z0-9_]{2,30}$ ]] || fail "Invalid demo user"
[[ "$demo_group" =~ ^[a-z][a-z0-9_]{2,30}$ ]] || fail "Invalid demo group"
[[ -r "$public_key" ]] || fail "Cannot read supplied public key: $public_key"
ssh-keygen -l -f "$public_key" >/dev/null || fail "Invalid public key"
entry="$(getent passwd "$demo_user")" || fail "User $demo_user does not exist"
IFS=: read -r name unused uid gid comment home shell <<< "$entry"
[[ "$uid" -ge 1000 && "$home" == "/home/$demo_user" && "$shell" == /bin/bash ]] ||
  fail "Unexpected UID, home directory or login shell"
pass "User $demo_user exists with home $home and shell /bin/bash"
getent group "$demo_group" >/dev/null || fail "Group $demo_group does not exist"
pass "Group $demo_group exists"
[[ "$(id -gn "$demo_user")" == "$demo_group" ]] || fail "Primary group mismatch"
pass "User belongs to primary group $demo_group"
for group in $(id -nG "$demo_user"); do
  case "$group" in
    root|sudo|adm|wheel|docker|lxd) fail "Unexpected privileged group: $group" ;;
  esac
done
pass "No membership in the checked privileged groups"
check_path() {
  local path="$1" mode="$2" kind="$3" actual
  [[ ! -L "$path" ]] || fail "Unexpected symbolic link: $path"
  if [[ "$kind" == dir ]]; then
    [[ -d "$path" ]] || fail "Missing directory: $path"
  else
    [[ -f "$path" ]] || fail "Missing file: $path"
  fi
  actual="$(stat -c '%U:%G:%a' -- "$path")" || fail "Cannot inspect $path; run with sudo"
  [[ "$actual" == "$demo_user:$demo_group:$mode" ]] ||
    fail "$path has $actual, expected $demo_user:$demo_group:$mode"
  pass "$path owner=$demo_user group=$demo_group mode=$mode"
}
check_path "$home" 700 dir
check_path "$home/.ssh" 700 dir
check_path "$home/.ssh/authorized_keys" 600 file
expected="$(cat -- "$public_key")"
grep -Fqx -- "$expected" "$home/.ssh/authorized_keys" ||
  fail "Supplied public key is absent from authorized_keys"
pass "Exact supplied public key is installed"
echo "ALL CHECKS PASSED"

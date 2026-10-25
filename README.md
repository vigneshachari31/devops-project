# A Standard Secure Configuration Applied to Every New Server

**Group 34**

Related experiment: **To automate system configuration and application deployment using Ansible Playbooks.**

## 1. Introduction
This project uses Ansible to create a standard Linux account configuration. It creates a user and group, installs an SSH public key, and protects the account's home and SSH files. The actual target is the Ubuntu instance running through WSL 2 on this computer.

## 2. Problem statement
Manually setting up every new server takes time. An administrator can forget a group, install a key for the wrong user, or leave incorrect permissions. A written, repeatable configuration makes the intended setup easier to inspect and reproduce.

## 3. Objectives
- Create the configurable demonstration user `devopsuser`.
- Create the group `devops` and make it the user's primary group.
- Install the public key with `ansible.posix.authorized_key`.
- Apply and independently verify a small account security baseline.
- Run twice and check that the second execution makes no unnecessary changes.

## 4. Existing manual approach
An administrator would run account-management commands, create directories, edit authorized_keys, and adjust ownership and permissions separately on each machine. Repeating these steps manually introduces omissions and inconsistent results.

## 5. Proposed solution
The playbook states the desired configuration. Ansible modules inspect the current state and change it when necessary. Verification then checks the real account database and filesystem. A test script checks the exit status and actual recaps from two executions.

This project implements the assigned configuration application. It does not deploy a web application or claim to provide complete production hardening.

## 6. Software and technologies
| Component | Used here |
|---|---|
| Host environment | Windows 11 with Ubuntu through WSL 2 |
| Controller and target | The same Ubuntu instance |
| Working user | vignesh |
| Ansible Core | 2.20.1, checked locally |
| ansible.posix | 2.1.0, checked locally |
| Python | 3.14.4 in the inspected environment |
| OpenSSH | ssh-keygen for key generation and validation |
| Configuration | YAML playbook and INI inventory |
| Verification | Bash, getent, id, stat, grep, and Python recap parsing |

## 7. Architecture
```text
Windows 11
  Ubuntu in WSL 2
    vignesh runs Ansible
        |
        +-- inventory.ini selects localhost
        +-- secure_server.yml describes desired state
        +-- files/devops.pub supplies ONLY the public key
        |
        +-- local connection (no SSH transport)
                |
                +-- group: devops
                +-- user: devopsuser, home: /home/devopsuser
                +-- .ssh/authorized_keys and secure permissions
                |
                +-- verification and second-run idempotency check
```

Ansible is both controller and target here. There is no separate server.
The key is installed in the standard location, but an SSH login was **not** tested.
A separate-server demonstration needs another reachable Linux target, an SSH login account,
host-key verification, suitable privilege escalation, and a remote inventory.
The final verification task uses a controller public-key path that works locally;
adapt it to transfer the public key or use remote verification before reusing this playbook over SSH.

## 8. Project structure
```text
secure-server-configuration/
  ansible.cfg
  inventory.ini
  secure_server.yml
  README.md
  .gitignore
  files/devops.pub
  .secrets/                 # Private, ignored; never share this directory
  scripts/
    setup_key.sh
    verify.sh
    test.sh
  results/                 # Actual execution evidence
  presentation/
    slide_outline.md
    project_explanation.md
    viva_questions.md
    demo_script.md
```

## 9. Basic concepts
| Term | Simple explanation |
|---|---|
| Ansible | A tool that automates configuration using modules |
| Inventory | A list of the computers Ansible manages |
| Playbook | An ordered set of tasks and the hosts they apply to |
| YAML | The indentation-based format used for the playbook |
| Module | A reusable operation such as managing a user or file |
| User | A Linux account with an identity, home and permissions |
| Group | A way to associate users with shared permissions |
| SSH | A protocol commonly used for secure remote login |
| Public key | The shareable part of a key pair, installed on a target |
| Private key | The secret part retained by the person authenticating |
| authorized_keys | The target user's list of accepted public keys |
| Idempotency | Reapplying the desired state without unnecessary changes |

## 10. Requirements
Ansible, Python, Bash and OpenSSH tools must be available in Ubuntu.
Account and group changes require root privileges through sudo or an approved WSL root session.
The existing Ansible and collection installations were reused; they were not reinstalled.

Check dependencies:
```bash
ansible --version
ansible-galaxy collection list ansible.posix
command -v ssh-keygen
```

Only on another machine where the collection is missing:
```bash
ansible-galaxy collection install ansible.posix:2.1.0
```

## 11. Setup and key handling
All commands in this README are for the **Ubuntu terminal**, unless explicitly labelled PowerShell.

```bash
cd /home/vignesh/secure-server-configuration
bash scripts/setup_key.sh
```

Setup has already been executed here. The script preserves existing key files.
The dedicated Ed25519 key locations are:
- Private key: `.secrets/group34_ed25519`, mode 600.
- Public companion: `.secrets/group34_ed25519.pub`.
- Public key supplied to Ansible: `files/devops.pub`, mode 644.
- Private directory: `.secrets/`, mode 700 and excluded from Git.

The demonstration private key has an empty passphrase for this disposable local exercise.
For real access, use a passphrase and appropriate key management. Do not email, screenshot,
commit, or upload the private key. Do not share an unfiltered ZIP of the entire project:
Git ignores do not protect ordinary ZIP archives.

Public-key login lets the client prove possession of the private key without sending that
private key to the server. This project installs the public half; it does not exercise that login.

The defaults are near the top of `secure_server.yml`.
To use different dedicated account names:
```bash
sudo ansible-playbook -i inventory.ini secure_server.yml -e demo_user=demooperator -e demo_group=demoteam
sudo bash scripts/verify.sh demooperator demoteam
```
Use only a fresh, non-administrative demo account. The preflight refuses unrelated existing users.
The home follows the username; it must remain `/home/<demo_user>`.

## 12. Execution
First validate the inventory and syntax:
```bash
cd /home/vignesh/secure-server-configuration
ansible-inventory --graph
ansible-config dump --only-changed
ansible-playbook secure_server.yml --syntax-check
```

Apply the configuration:
```bash
sudo ansible-playbook -i inventory.ini secure_server.yml
```
Enter your **Ubuntu sudo password** at the sudo password prompt. Input is hidden.
No password belongs in inventory or source files.

Run the same command a second time:
```bash
sudo ansible-playbook -i inventory.ini secure_server.yml
```
Because the project is already configured, both runs during tomorrow's presentation should
normally report `changed=0`. The original first-run evidence is saved in `results/first_run.txt`.
Do not delete the account just to obtain a changed result.

For the automated suite:
```bash
sudo bash scripts/test.sh
```
This requests sudo authentication if needed, checks syntax and inventory, runs twice, parses
the recaps, and runs verification. It overwrites the corresponding files in `results/`;
copy the original evidence elsewhere in the project first if you need to retain the original
`changed=5` result. A later suite's first run may correctly report zero changes.

## 13. Playbook tasks and security settings
| Task | Purpose |
|---|---|
| Validate names | Avoid the current user, root and common privileged groups |
| Validate public key | Fail before account changes if ssh-keygen rejects the input |
| Inspect existing account | Read passwd information without changing it |
| Check account ownership | Refuse to repurpose an unrelated existing account |
| group module | Ensure devops exists |
| user module | Ensure devopsuser has primary group devops, a home and /bin/bash |
| Home permissions | Owner devopsuser, group devops, mode 0700 |
| SSH directory | Owner devopsuser, group devops, mode 0700 |
| authorized_key module | Add the supplied public key and preserve other authorized keys |
| Authorized keys permissions | Owner devopsuser, group devops, mode 0600 |
| Independent verification | Fail the play if account, key, ownership or permissions are wrong |

Mode **700** means the owner can read, write and traverse the directory; group and others
have no permissions. Mode **600** means only the owner can read and write the file.
Linux root can still administer these paths. These settings protect the demo account's files.

The new account gets no administrator-group membership or sudoers entry.
No password is assigned; this is not a tested password-login account.
No system-wide SSH settings, root-login policies, firewall rules, or existing user access
methods are changed. This is a small account baseline, not a security certification.

The script task is read-only and uses `changed_when: false`. State-changing work uses
Ansible modules. Privilege escalation is scoped to account/file configuration and verification.

## 14. Verification commands
```bash
getent passwd devopsuser
getent group devops
id devopsuser
sudo stat -c '%U:%G %a %n' /home/devopsuser /home/devopsuser/.ssh /home/devopsuser/.ssh/authorized_keys
ssh-keygen -lf files/devops.pub
sudo ssh-keygen -lf /home/devopsuser/.ssh/authorized_keys
sudo bash scripts/verify.sh
```

The two key fingerprints should match for this single-key demo.
The script checks the exact supplied public-key line as well as ownership and modes.
Expect `ALL CHECKS PASSED` and exit status 0; any required condition failure returns nonzero.
A primary group member may not appear in the comma-separated member list from `getent group`.
Use `id devopsuser` to show the user's actual membership.

## 15. Actual test results
Testing was performed on **25 October 2026 (Asia/Calcutta)**.
See `results/executed_at_utc.txt` for the machine-recorded execution timestamp.

| Check | Actual outcome |
|---|---|
| YAML/playbook syntax | Passed |
| Inventory | localhost under demo_servers |
| Project configuration | Correct ansible.cfg and local inventory loaded |
| First playbook run | ok=11, changed=5, unreachable=0, failed=0 |
| Second playbook run | ok=11, changed=0, unreachable=0, failed=0 |
| Independent verification | Eight PASS checks and ALL CHECKS PASSED |
| Idempotency parser | Passed; second execution changed zero tasks |

Both recaps also reported skipped=0, rescued=0 and ignored=0.
The authorized_keys permission task was already satisfied by key installation on the first run,
so six configuration tasks produced five changes.

Tests were executed with an approved **WSL root invocation**, because unattended
`sudo -n true` as vignesh required interactive authentication.
The user later verified direct sudo execution successfully: sudo ansible-playbook -i inventory.ini secure_server.yml. Ansible's internal sudo authentication failed in this environment, so use direct sudo for the demonstration.
The private key was generated as vignesh. Test log ownership was returned to vignesh.

The installed ansible.posix module emitted a deprecation warning about importing
`to_native` from `ansible.module_utils._text`. Both runs still succeeded. No package
upgrade or warning suppression was needed for this demonstration.

An initial permission-inspection command failed because of shell quoting; the Ansible
syntax and inventory checks in that command had passed. File permissions were subsequently
checked separately. No failed playbook run is being reported as a success.

Negative-test and key-permission evidence is in `results/additional_checks.txt`.
Remote SSH login, deployment to another server, and full production hardening remain outside
the tested scope. No screenshots are claimed; use the capture instructions in the demo script.

## 16. Idempotency
Idempotency means the desired state already exists after the first successful run.
The modules do not recreate the user, group or key on each execution.
The measured second run was `changed=0`, with no failed or unreachable tasks.
Read-only checks reporting `ok` do not mean verification was skipped.

## 17. Advantages and limitations
Advantages: less repeated typing, consistent settings, readable configuration, reusable
parameters, and verifiable results.

Limitations: one local Ubuntu target; no proven network SSH login; one demo user/group per
run; a deliberately small baseline; the verification task currently assumes a local key path.
Keeping other authorized keys protects existing access, but this project does not enforce
an exclusive approved-key list. Checking common privileged groups is not a full sudo policy audit.

## 18. Possible future enhancements
Use an isolated VM for remote SSH testing, support a list of users, organize reusable roles,
add automated CI validation, introduce Ansible Vault for genuine secrets, and design
distribution-specific hardening with a recovery plan. These are future work, not implemented features.

## 19. Presentation materials
- `presentation/slide_outline.md`: 10 slides with speaker notes.
- `presentation/project_explanation.md`: plain-language explanation and assignment mapping.
- `presentation/viva_questions.md`: 25 questions and answers.
- `presentation/demo_script.md`: exact demo commands and screenshot guidance.

## 20. Common errors and troubleshooting
| Message or symptom | Action |
|---|---|
| Missing sudo password | Run sudo ansible-playbook -i inventory.ini secure_server.yml and enter the Ubuntu password |
| Incorrect sudo password | Retry in Ubuntu; never paste it into chat or source files |
| Module authorized_key not found | Check ansible-galaxy collection list ansible.posix; install only if missing |
| files/devops.pub is missing | Run bash scripts/setup_key.sh as vignesh; it will refuse a partial existing pair |
| Existing account rejected | Choose a fresh dedicated demo username; do not remove the safety check |
| Permission denied during verification | Run sudo bash scripts/verify.sh |
| localhost not in inventory | Run from the project directory and inspect ansible-inventory --graph |
| Second run changes something | Read the changed task and inspect manual edits; do not claim idempotency until a subsequent run has zero changes |
| getent group shows no members | devops is the primary group; confirm with id devopsuser |
| Deprecation warning | The tested versions worked; review collection compatibility before a future Core upgrade |
| Files fail from a Windows terminal | Run the documented Bash commands in Ubuntu/WSL |
| SSH login fails | SSH connectivity was not tested; check the service, account policy, network and key separately |

Keep the project in the WSL Linux filesystem so Linux permissions are meaningful.
Syntax validation does not prove runtime correctness; the actual execution and independent checks do.

## 21. Conclusion
The implementation satisfies the assigned user/group creation and authorized_key requirements.
The tested local baseline includes appropriate ownership and permissions, and the second run
demonstrated zero unnecessary changes. The same configuration-management idea can be extended
to separate servers after adapting inventory, access and verification.

## References
- [Ansible user module](https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/user_module.html)
- [Ansible authorized_key module](https://docs.ansible.com/projects/ansible/latest/collections/ansible/posix/authorized_key_module.html)

The online documentation can describe newer releases. Execution here used the locally
installed versions recorded in `results/environment.txt`.

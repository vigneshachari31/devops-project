# A Standard Secure Configuration Applied to Every New Server

**Group 34**

## One-minute explanation
Our project automates the basic account setup of a Linux server with Ansible.
Instead of creating users, groups and SSH files manually, we describe the required configuration
in a YAML playbook. The playbook creates devopsuser and devops, makes devops the user's primary
group, installs a public key with ansible.posix.authorized_key, and sets safe file permissions.
We then verify the actual system state and run the playbook again.

In our implementation, Ansible runs inside WSL Ubuntu and configures that same Ubuntu using a
local connection. This demonstrates configuration automation. We have not demonstrated a remote
SSH connection or an SSH login using the installed key.

## Experiment versus assigned project
The related experiment is: **To automate system configuration and application deployment using Ansible Playbooks.**
That is the broad laboratory topic. Our assigned project is:
**A Standard Secure Configuration Applied to Every New Server**.
It applies the system-configuration part of that topic to user, group and SSH-key management.
A separate application deployment is not part of the assigned mandatory functionality.

## How the requirements are met
| Requirement | Implementation | Evidence |
|---|---|---|
| Create users | ansible.builtin.user creates devopsuser | getent passwd and verifier |
| Create groups | ansible.builtin.group creates devops | getent group and verifier |
| Group membership | devops is the user's primary group | id devopsuser |
| Install SSH keys | ansible.posix.authorized_key | Exact public-key comparison |
| Safe baseline | Home and .ssh 700; authorized_keys 600; correct ownership | stat and verifier |
| Verification | scripts/verify.sh exits nonzero on failure | results/verification.txt |
| Repeatability | Actual second execution | results/second_run.txt: changed=0 |

## Files to explain
inventory.ini selects localhost with a local connection.
ansible.cfg sets project inventory and Python.
secure_server.yml describes the desired state and runs verification.
files/devops.pub contains the public key.
scripts/setup_key.sh creates the dedicated key pair without overwriting existing files.
scripts/verify.sh independently reads the account database and file metadata.
scripts/test.sh runs validation, two executions, recap checking and verification.

## Actual observed outcome
First run: **ok=11 changed=5 unreachable=0 failed=0**.
Second run: **ok=11 changed=0 unreachable=0 failed=0**.
Independent verification: **ALL CHECKS PASSED**.
These tests ran through an approved WSL root session. Normal presentation commands use sudo.
The installed collection emitted a deprecation warning; it did not prevent execution.

## Security explanation
The demo account has no added administrator privileges. Only its owner can normally access
its private home and SSH directory. Only its owner can read or modify authorized_keys.
Root retains administrative access. The public key is installed on the target; the private
key remains in the controller's protected, ignored .secrets directory.
The demonstration key has no passphrase and must not be reused for real access.

We preserve existing login methods and system-wide SSH settings. A small account baseline
does not mean the entire server has been hardened or certified secure.

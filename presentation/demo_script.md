# A Standard Secure Configuration Applied to Every New Server

**Group 34 — approximately 5 minutes**

Use an **Ubuntu terminal**. Increase the terminal font so the output is readable.
Never open the private key or .secrets directory during screen sharing.

## 1. Introduce the project (30 seconds)
Say: "We use Ansible to apply a consistent Linux account configuration. Our mandatory tasks
are creating users and groups and installing SSH keys using authorized_key."

```bash
cd /home/vignesh/secure-server-configuration
ansible-inventory --graph
cat inventory.ini
```

Show localhost under demo_servers and ansible_connection=local.
Say: "This is the same WSL Ubuntu instance as both controller and target. This is not a remote SSH demonstration."

## 2. Explain the playbook (45 seconds)
Open secure_server.yml in VS Code.
Point to the user/group variables and the group, user, file and authorized_key tasks.
Say: "The account has no administrator privileges. The home and SSH directory are 700;
authorized_keys is 600. Existing system-wide login settings are preserved."

## 3. Validate and execute (90 seconds)
```bash
ansible-playbook secure_server.yml --syntax-check
sudo ansible-playbook -i inventory.ini secure_server.yml
```

Enter your Ubuntu sudo password privately at the hidden prompt.
Show the PLAY RECAP and failed=0.
The machine is already configured, so changed=0 is the expected live result.
A deprecation warning from the installed collection may appear; the tested run still succeeded.

## 4. Verify the real state (60 seconds)
```bash
id devopsuser
getent passwd devopsuser
getent group devops
sudo bash scripts/verify.sh
```

Show the primary group, home, shell, eight PASS lines and ALL CHECKS PASSED.
Say: "The script checks the actual files and account database, and returns a failure status if a condition is wrong."

## 5. Demonstrate idempotency (60 seconds)
```bash
sudo ansible-playbook -i inventory.ini secure_server.yml
```

Show changed=0, unreachable=0 and failed=0 in the recap.
Say: "Ansible maintains the desired state. Running it again does not recreate the same resources."

To show the saved original evidence:
```bash
cat results/idempotency.txt
cat results/verification.txt
```

Actual original results from testing:
- First execution: ok=11 changed=5 unreachable=0 failed=0.
- Second execution: ok=11 changed=0 unreachable=0 failed=0.
- Both: skipped=0 rescued=0 ignored=0.
- Independent verification: ALL CHECKS PASSED.

Saved testing used an approved WSL root session because unattended sudo required a password.
Do not describe those saved runs as normal-user password-prompt tests.

## 6. Conclude (15 seconds)
Say: "We met the assigned requirements and demonstrated repeatability. A future version can
manage a separate server over SSH, but this demonstration proves local configuration only."

## Screenshot checklist
Capture real terminal output with Windows **Win+Shift+S**:
1. Inventory graph and local connection setting.
2. Original saved first-run recap: `tail -n 4 results/first_run.txt`.
3. A live repeated-run recap showing zero changes.
4. Verifier output showing ALL CHECKS PASSED.

Label saved output as original recorded output. Keep the title visible in the playbook/editor
where practical. Crop out unrelated windows. Do not capture passwords or private key material.
No screenshots were generated as part of the automated testing.

## If something goes wrong
For sudo authentication, use the direct sudo command shown above.
For a permission error in the verifier, use sudo.
If a task fails or changes unexpectedly, explain that result honestly and inspect it.
Use the saved successful logs as recorded evidence if the live run cannot be completed;
do not present saved logs as a live execution.

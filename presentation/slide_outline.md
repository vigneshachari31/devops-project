# A Standard Secure Configuration Applied to Every New Server

**Group 34 — 10-slide presentation outline with speaker notes**

This is a Markdown outline ready to transfer into PowerPoint; it is not a generated PPTX.

## Slide 1 — A Standard Secure Configuration Applied to Every New Server
- Group 34
- Related experiment: To automate system configuration and application deployment using Ansible Playbooks.

**Speaker notes:** Our assigned application is to apply a standard account configuration to new Linux servers. We demonstrate it using Ubuntu through WSL.

## Slide 2 — Problem statement
- Repeating account setup manually takes time.
- Incorrect groups, keys or permissions cause inconsistent access.
- We need a repeatable configuration and a way to verify it.

**Speaker notes:** Even a short checklist can be applied differently on different machines. A playbook records the intended configuration.

## Slide 3 — Project objectives
- Create a Linux user and group.
- Install the user's SSH public key.
- Apply appropriate ownership and permissions.
- Verify the result and run again to test idempotency.

**Speaker notes:** User/group creation and authorized_key are the mandatory assignment requirements.

## Slide 4 — Introduction to Ansible
- Inventory identifies targets.
- YAML playbooks describe tasks.
- Modules manage resources.
- Privilege escalation permits required administrative operations.

**Speaker notes:** We use built-in user, group and file modules plus ansible.posix.authorized_key. The playbook describes the desired state instead of blindly repeating commands.

## Slide 5 — System architecture and workflow
- Controller: WSL Ubuntu.
- Target: the same WSL Ubuntu, using a local connection.
- Workflow: validate input, apply configuration, verify, run again.

**Speaker notes:** There is no separate target machine. Installing the key demonstrates account configuration; it does not prove an SSH login.

## Slide 6 — Tools and technologies
- Windows 11 and Ubuntu through WSL 2
- Ansible Core 2.20.1 and ansible.posix 2.1.0
- OpenSSH key tools, Python and Bash
- VS Code, YAML and INI files

**Speaker notes:** Existing Ansible installations were reused. Public keys can be shared; private keys stay protected and are excluded from Git.

## Slide 7 — Playbook implementation
- User devopsuser, primary group devops, shell /bin/bash
- Public key installed with ansible.posix.authorized_key
- Home and .ssh: 700; authorized_keys: 600
- Correct owner/group; no added administrative privileges

**Speaker notes:** Preflight rejects unrelated existing accounts. Other authorized keys are preserved. No system-wide SSH or firewall settings are changed.

## Slide 8 — Demonstration and actual test results
| Execution | OK | Changed | Failed |
|---|---:|---:|---:|
| First run | 11 | 5 | 0 |
| Second run | 11 | 0 | 0 |

- Independent verification: ALL CHECKS PASSED
- Inventory and syntax validation passed
- No unreachable targets

**Speaker notes:** These are actual saved results from the approved WSL root test. The normal demo uses sudo. The second run proves idempotency for the tested state. A collection deprecation warning appeared but did not prevent success. Show results/idempotency.txt and the verifier.

## Slide 9 — Advantages and limitations
- Consistent configuration and less repeated manual work
- Readable settings and independent verification
- Tested on one local target
- Remote SSH login and broader production hardening are future work

**Speaker notes:** The title describes the general application. Our implementation demonstrates a small account baseline, not a complete server security audit.

## Slide 10 — Conclusion
- User and group creation completed.
- SSH public-key installation and permissions verified.
- Second execution made zero changes.
- Future work: separate SSH target and reusable multi-user configuration.

**Speaker notes:** The experiment covers configuration and application deployment broadly. Our assigned project implements the configuration portion. The required functionality is complete and supported by recorded output.

## Reference notes
- [Ansible user module](https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/user_module.html)
- [Ansible authorized_key module](https://docs.ansible.com/projects/ansible/latest/collections/ansible/posix/authorized_key_module.html)
- Local execution evidence: ../results/first_run.txt, ../results/second_run.txt, ../results/verification.txt

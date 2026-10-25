# A Standard Secure Configuration Applied to Every New Server

**Group 34 — Viva questions**

1. **What does your project do?** It automates a Linux user's creation, group membership, SSH public-key installation and secure file permissions.
2. **What is Ansible?** A configuration automation tool that executes tasks through reusable modules.
3. **What is a playbook?** A YAML document describing which tasks run on which hosts.
4. **What is YAML?** A human-readable data format where indentation defines structure.
5. **What is an inventory?** A list of managed hosts and connection settings.
6. **What is the controller?** The machine running Ansible; here it is WSL Ubuntu.
7. **What is the managed target?** The computer receiving configuration; here it is that same Ubuntu instance.
8. **Why use a local connection?** It lets us demonstrate configuration without needing another machine or SSH transport.
9. **Have you demonstrated remote SSH access?** No. We installed a key, but all configuration ran locally.
10. **Which module creates the user?** ansible.builtin.user.
11. **Which module creates the group?** ansible.builtin.group.
12. **Which module installs the public key?** Exactly ansible.posix.authorized_key, from the ansible.posix collection.
13. **What is a collection?** A packaged set of Ansible content, such as modules and plugins.
14. **What is SSH?** A protocol commonly used to establish authenticated, encrypted remote sessions.
15. **What is the difference between public and private keys?** The public key may be shared with a target. The private key must remain secret and proves the client's identity.
16. **Where is the authorized key installed?** /home/devopsuser/.ssh/authorized_keys.
17. **Where is the private key?** In the project's ignored .secrets/group34_ed25519 file, protected by mode 600. We never display its contents.
18. **What is a Linux group used for?** It associates users with shared permissions. Here devops is devopsuser's primary group.
19. **Why can getent group show an empty member list?** Primary group membership is recorded through the user's group ID. id devopsuser shows the effective membership.
20. **What do permissions 700 and 600 mean?** 700 gives only the owner directory read/write/traverse permissions. 600 gives only the owner file read/write permissions. Root can still administer them.
21. **What is become?** Ansible privilege escalation, needed for account creation and protected files. The usual local method is sudo.
22. **What is idempotency, and did you test it?** Repeating the desired configuration causes no unnecessary changes. Our actual second run reported changed=0 and failed=0.
23. **How do you verify the result?** The script checks account data, membership, key contents, ownership and modes, and exits nonzero on a failure.
24. **What were your actual execution results?** The first run reported ok=11 changed=5 failed=0; the second reported ok=11 changed=0 failed=0. Verification passed. There was a nonfatal collection deprecation warning.
25. **What are the limitations and future improvements?** One local target and a small baseline were tested. Future work could add a separate SSH target, more users, roles and broader hardening with recovery planning.

Do not claim a full security audit, production readiness, or a tested SSH login.

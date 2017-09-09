# -*- mode: ansible -*-
# vi: set ft=ansible :

---
- name: PROJECT provisioning
  hosts: PROJECT
  roles:
    - common
    - dovecot
    - postfix
    - dkim
    - mlmmj

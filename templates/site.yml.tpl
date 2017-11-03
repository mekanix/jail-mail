# -*- mode: ansible -*-
# vi: set ft=ansible :

---
- name: SERVICE provisioning
  hosts: SERVICE
  roles:
    - common
    - dovecot
    - postfix
    - dkim
    - mlmmj
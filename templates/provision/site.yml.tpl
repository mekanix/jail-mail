# -*- mode: ansible -*-
# vi: set ft=ansible :

---
- name: PROJECT provisioning
  hosts: PROJECT
  roles:
    - common
    - letsencrypt
    - ldap
    - dovecot
    - postfix
    - dkim

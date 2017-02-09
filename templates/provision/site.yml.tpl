# -*- mode: ansible -*-
# vi: set ft=ansible :

---
- name: PROJECT provisioning
  hosts: PROJECT
  roles:
    - common
    - ldap
    - dovecot
    - postfix
    - dkim
    - rainloop

- name: PROJECT localhost provisioning
  hosts: localhost
  roles:
    - localhost

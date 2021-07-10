# -*- mode: ansible -*-
# vi: set ft=ansible :

---
- name: SERVICE provisioning
  hosts: SERVICE
  roles:
    - onelove-roles.freebsd-common
    - repo
    - rspamd
    - dovecot
    - postfix
    - ldap
    - mlmmj

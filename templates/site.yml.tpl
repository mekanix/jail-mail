# -*- mode: ansible -*-
# vi: set ft=ansible :

---
- name: SERVICE provisioning
  hosts: SERVICE
  roles:
    - onelove-roles.freebsd-common
    - onelove-roles.freebsd-consul-template
    - repo
    - rspamd
    - dovecot
    - postfix
    - mlmmj

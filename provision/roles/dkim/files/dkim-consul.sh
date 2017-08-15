#!/bin/sh

chmod 600 /usr/local/etc/mail/dkim.key
service milter-opendkim restart

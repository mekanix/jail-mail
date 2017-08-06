#!/bin/sh

export PROVIDER={{ key "mail/letsencrypt/provider" }}
export LEXICON_VULTR_USERNAME={{ key "mail/letsencrypt/username" }}
export LEXICON_VULTR_TOKEN={{ key "mail/letsencrypt/token" }}

/usr/local/bin/dehydrated --cron --hook /root/bin/hook.sh --challenge dns-01 --domain {{ key "mail/domain" }} --domain mail.{{ key "mail/domain" }}

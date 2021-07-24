# Mail Service

To create mail service/jail, the following software will be installed and
configured:

* [Postfix](#postfix) (smtp, submission)
* [Dovecot](#dovecot) (imap, sieve)
* [RSpamd](#rspamd) (spam, dkim, dmarc, spf, ...)
* [Mlmmj](#mlmmj) (mailing list)
* [Hypermail](#hypermail) (web archive for mailing lists)

Installed postfix and dovecot are built with LDAP support. You should check out 
[LDAP repo](https://github.com/mekanix/jail-ldap) especially `examples` as that
schema is going to be used here.

## Postfix
main.cf:
```
virtual_mailbox_domains = ldap:domains
virtual_alias_maps = ldap:aliases
transport_maps = ldap:transport
virtual_mailbox_maps = ldap:mailboxes
```
Postfix has 4 main sections where LDAP is used:
* Domains (ldap:domains)
* Aliases (ldap:aliases) - send everything for user@example.com to some@one.com
* Transport Maps (ldap:transport) - how the message should be delivered
* Mailboxes (ldap:mailboxes) - the final destination for mail

If we change `ldap:domains` into `ldap:d`, that means that all `domains_*`
variables below should become `d_*`, too. Same applies to all `ldap:*`
variables.

main.cf:
```
virtual_transport = dovecot
dovecot_destination_recipient_limit = 1
mlmmj_destination_recipient_limit = 1
```
Deliver mail using dovecot LDA and set concurency to 1 for dovecot and mlmmj
transports.

main.cf:
```
domains_server_host = ldap.{{ mail_domain }}
domains_search_base = dc=account, dc=ldap
domains_query_filter = (&(ou=%s)(objectClass=organizationalUnit))
domains_result_attribute = ou
domains_scope = one
domains_cache = no
domains_bind = no
domains_version = 3
domains_start_tls = yes
```
If domain is not found, the mailbox is not on this server.

main.cf:
```
aliases_server_host = ldap.{{ mail_domain }}
aliases_search_base = ou=%d, dc=account, dc=ldap
aliases_query_filter = (&(uid=%u)(objectClass=person)(userClass=mail))
aliases_result_attribute = otherMailbox
aliases_scope = one
aliases_cache = no
aliases_bind = no
aliases_version = 3
aliases_start_tls = yes
```
Alias example: deliver all user@example.com mail to some@one.com. Aliases are
also used to denote to postfix that although there is no mailbox for mailing
list, it should still process it.

main.cf:
```
transport_server_host = ldap.tilda.center
transport_search_base = ou=%d, dc=account, dc=ldap
transport_query_filter = (&(uid=%u)(objectClass=person)(userClass=mail))
transport_result_attribute = textEncodedORAddress
transport_scope = one
transport_cache = no
transport_bind = no
transport_version = 3
transport_start_tls = yes
```
Transport, if found in `textEncodedORAddress` attribute, is used to pass
message to mailing list software. If no transport configuration is found in
LDAP, dovecot LDA is used by default. Note that mailing list in LDAP is just an
alias with `textEncodedORAddress` set.

main.cf:
```
mailboxes_server_host = ldap.{{ mail_domain }}
mailboxes_search_base = ou=%d, dc=account, dc=ldap
mailboxes_query_filter = (&(uid=%u)(objectClass=person)(userClass=mail))
mailboxes_result_attribute = mail
mailboxes_scope = one
mailboxes_cache = no
mailboxes_bind = no
mailboxes_version = 3
mailboxes_start_tls = yes
```
Final destination for mail.

master.cf:
```
dovecot unix    -       n       n       -       -       pipe
  flags=DRhu user=nobody:nobody argv=/usr/local/libexec/dovecot/deliver -d ${user}@${nexthop}
```
Dovecot's LDA is used. Note the `nexthop`. It enables
user+something@example.com to be treated as user@example.com. This is
especially useful with filtering (sieve)

master.cf:
```
mlmmj   unix  -       n       n       -       -       pipe
  flags=ORhu user=mlmmj argv=/usr/local/bin/mlmmj-helper ${nexthop}
```
If transport in LDAP told Postfix to use mlmmj, pipe email through mlmmj-helper.

## Dovecot

dovecot-ldap.conf.ext:
```
auth_bind = yes
ldap_version = 3
base = ou=%d, dc=account, dc=ldap
scope = onelevel

user_filter = (&(objectClass=person)(uid=%n)(userClass=mail))
pass_attrs = uid=user,userPassword=password,\
  homeDirectory=userdb_home,uidNumber=userdb_uid,gidNumber=userdb_gid
pass_filter = (&(objectClass=person)(uid=%n)(userClass=mail))
```
As Dovecot only has mailboxes and passwords, it's LDAP configuration is 
simpler. 

90-imapsieve.conf:
```
plugin {
  sieve_plugins = sieve_imapsieve sieve_extprograms

  # From elsewhere to Spam folder
  imapsieve_mailbox1_name = Spam
  imapsieve_mailbox1_causes = COPY
  imapsieve_mailbox1_before = file:/usr/local/etc/dovecot/sieve/report-spam.sieve

  # From Spam folder to elsewhere
  imapsieve_mailbox2_name = *
  imapsieve_mailbox2_from = Spam
  imapsieve_mailbox2_causes = COPY
  imapsieve_mailbox2_before = file:/usr/local/etc/dovecot/sieve/report-ham.sieve

  sieve_pipe_bin_dir = /usr/local/etc/dovecot/sieve

  sieve_global_extensions = +vnd.dovecot.pipe
}
```
If mail is moved from any folder into SPAM, Dovecot will run `report-spam.sieve` 
to train RSpamd. Similar happens when mail is moved out of SPAM folder.

after.sieve:
```
require ["fileinto", "mailbox", "imap4flags"];

if header :contains "X-Spam" "Yes" {
  fileinto :create "Spam";
  setflag "\\seen";
  stop;
}
```
Move all mails marked as SPAM to SPAM folder.

10-master.conf:
```
service auth {
  unix_listener auth-userdb {
  }

  # Postfix smtp-auth
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }
}
```
Postfix will use Dovecot's SASL authentication (avoid using Cyrus just for 
that).

## RSpamd

dkim_signing.conf:
```
selector = "{{ hoster.stdout }}";
allow_username_mismatch = true;
path = "/var/db/rspamd/dkim/$domain.$selector.key";
```
Selector is what tells receiving SMTP server which DNS record to check for
DKIM and `hoster.stdout` will be replaced with host's (not jail) hostname.

milter_headers.conf:
```
extended_spam_headers = true;
use = ["x-spam-status"];
```
If mail is SPAM, add header denoting the SPAM status.

## Mlmmj

Every mailing list in LDAP is just an alias with `textEncodedORAddress` set to
mlmmj (transport). That means all mail with mlmmj transport will be piped to
a mlmmj for check and delivery and if successful pipe it to Hypermail for 
archiving. To create a new list run `new-mlmmj-list.sh <list address> <owner>`.
For example:
```
new-mlmmj-list.sh list@example.com user@example.com
```
All lists are in `~mlmmj/lists/<list name>`.

## Hypermail

To generate WEB archive of public mailing lists, Hypermail uses small Python 
script which strips attachments and all non-essential headers. The script is 
`decode-mail.py`. The archive is placed under `~mlmmj/webarchive/<list name>`.

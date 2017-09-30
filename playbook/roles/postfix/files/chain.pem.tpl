{{ with $domain := key "mail/domain" }}{{ with $key := printf "letsencrypt/mail.%s/chain" $domain}}{{ key $key }}{{ end }}{{ end }}

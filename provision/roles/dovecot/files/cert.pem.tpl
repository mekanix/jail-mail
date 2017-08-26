{{ with $domain := key "mail/domain" }}{{ with $key := printf "letsencrypt/mail.%s/cert" $domain}}{{ key $key }}{{ end }}{{ end }}

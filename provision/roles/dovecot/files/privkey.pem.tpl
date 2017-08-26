{{ with $domain := key "mail/domain" }}{{ with $key := printf "letsencrypt/mail.%s/privkey" $domain}}{{ key $key }}{{ end }}{{ end }}

{{ with $domain := key "mail/domain" }}{{ with $key := printf "letsencrypt/mail.%s/fullchain" $domain}}{{ key $key }}{{ end }}{{ end }}

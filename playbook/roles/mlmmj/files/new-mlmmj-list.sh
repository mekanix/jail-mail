#!/bin/sh

LIST_ADDRESS=$1
OWNER=$2
LIST_NAME=`echo ${LIST_ADDRESS} | cut -f 1 -d '@'`
LIST_URL=`echo ${LIST_ADDRESS} | cut -f 2 -d '@'`

help() {
	echo "Usage: $0 list_email owner_email"
}

if [ -z "${LIST_ADDRESS}" ]; then
	help >&2
	exit 1
fi

if [ -z "${OWNER}" ]; then
	help >&2
	exit 1
fi

if [ -z "${LIST_NAME}" ]; then
	help >&2
	exit 1
fi

if [ -z "${LIST_URL}" ]; then
	help >&2
	exit 1
fi


printf "${LIST_URL}\n${OWNER}\n\ny\n" | mlmmj-make-ml -L "${LIST_NAME}" -s /usr/home/mlmmj/lists -c mlmmj
echo "Reply-To: ${LIST_ADDRESS}" >"/usr/home/mlmmj/lists/${LIST_NAME}/control/customheaders"
echo "To unsubscribe send email to ${LIST_NAME}+unsubscribe@${LIST_URL}" >"/usr/home/mlmmj/lists/${LIST_NAME}/control/footer"
echo "${LIST_URL}--${LIST_NAME}@localhost.mlmmj mlmmj:${LIST_NAME}" >>/usr/local/etc/postfix/transport
postmap /usr/local/etc/postfix/transport
service postfix reload

cat <<EOF
dn: uid=${LIST_NAME},ou=${LIST_URL},dc=ldap
objectClass: top
objectClass: person
objectClass: posixAccount
objectClass: shadowAccount
objectClass: pilotPerson
cn: ${LIST_NAME} list
sn: list
uid: ${LIST_ADDRESS}
uidNumber: 65534
gidNumber: 65534
homeDirectory: /var/mail/domains/${LIST_URL}/${LIST_NAME}
loginShell: /bin/false
gecos: System User
shadowLastChange: 13979
shadowMax: 45
mail: ${LIST_URL}--${LIST_NAME}@localhost.mlmmj
userClass: mail
EOF

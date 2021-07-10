#!/bin/sh

LIST_ADDRESS=$1
OWNER=$2
LIST_NAME=`echo ${LIST_ADDRESS} | cut -f 1 -d '@'`
LIST_DOMAIN=`echo ${LIST_ADDRESS} | cut -f 2 -d '@'`

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

if [ -z "${LIST_DOMAIN}" ]; then
	help >&2
	exit 1
fi


SPOOL_DIR="/usr/home/mlmmj/lists/${LIST_DOMAIN}"
printf "${LIST_DOMAIN}\n${OWNER}\n\ny\n" | mlmmj-make-ml -L "${LIST_NAME}" -s "${SPOOL_DIR}" -c mlmmj
echo "Reply-To: ${LIST_ADDRESS}" >"${SPOOL_DIR}/${LIST_NAME}/control/customheaders"
echo -e "\n---\nTo unsubscribe send email to ${LIST_NAME}+unsubscribe@${LIST_DOMAIN}" >"${SPOOL_DIR}/${LIST_NAME}/control/footer"
echo "[${LIST_NAME}]" >"${SPOOL_DIR}/${LIST_NAME}/control/prefix"

cat <<EOF | ldapadd -Z -W -D cn=root,dc=ldap
dn: uid=${LIST_NAME},ou=${LIST_DOMAIN},dc=account,dc=ldap
objectClass: pilotPerson
objectClass: posixAccount
cn: List ${LIST_NAME}
sn: ${LIST_NAME}
uidNumber: 65534
gidNumber: 65534
homeDirectory: /var/mail/domains/${LIST_DOMAIN}/${LIST_NAME}
textEncodedORAddress: mlmmj:${LIST_DOMAIN}/${LIST_NAME}
otherMailbox: ${LIST_NAME}@${LIST_DOMAIN}
userClass: mail
EOF

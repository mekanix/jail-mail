SERVICE = mail
REGGAE_PATH = /usr/local/share/reggae
PORTS = 25 587 993 12345
SELECTOR ?= mail

post_setup_ansible:
	@echo "mail_domain: ${FQDN}" >>ansible/group_vars/all
	@echo "mail_selector: ${SELECTOR}" >>ansible/group_vars/all

.include <${REGGAE_PATH}/mk/service.mk>

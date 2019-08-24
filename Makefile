SERVICE = mail
REGGAE_PATH = /usr/local/share/reggae
EXTRA_FSTAB = templates/fstab
PORTS = 25 587 993 995

post_setup_ansible:
	@echo "mail_domain: ${FQDN}" >>ansible/group_vars/all

.include <${REGGAE_PATH}/mk/ansible.mk>
.include <${REGGAE_PATH}/mk/service.mk>

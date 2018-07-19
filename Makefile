SERVICE = mail
REGGAE_PATH = /usr/local/share/reggae
EXTRA_FSTAB = templates/fstab

.include <${REGGAE_PATH}/mk/ansible.mk>
.include <${REGGAE_PATH}/mk/service.mk>

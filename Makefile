.if exists(vars.mk)
.include <vars.mk>
.endif

.include <include.mk>


provision: up
	@sudo ansible-playbook -i provision/inventory/${INVENTORY} provision/site.yml

up: setup
	@sudo cbsd jcreate jconf=${PWD}/cbsd.conf || true
	@sudo cp templates/fstab.custom.local /cbsd/jails-fstab/fstab.${PROJECT}.local
.if !exists(/cbsd/jails-system/${PROJECT}/master_poststart.d/register.sh)
	@sudo ln -s /usr/local/bin/cbsd-devops /cbsd/jails-system/${PROJECT}/master_poststart.d/register.sh
.endif
.if !exists(/cbsd/jails-system/${PROJECT}/master_poststop.d/deregister.sh)
	@sudo ln -s /usr/local/bin/cbsd-devops /cbsd/jails-system/${PROJECT}/master_poststop.d/deregister.sh
.endif
	@sudo chown ${UID}:${GID} cbsd.conf
	@sudo cbsd jstart ${PROJECT} || true

down: setup
	@sudo cbsd jstop ${PROJECT} || true

destroy: down
	@rm -f provision/inventory/${INVENTORY} provision/site.yml provision/group_vars/all cbsd.conf vars.mk
	@sudo cbsd jremove ${PROJECT}

setup:
	@sed -e "s:PROJECT:${PROJECT}:g" templates/provision/site.yml.tpl >provision/site.yml
	@sed -e "s:PROJECT:${PROJECT}:g" templates/provision/inventory.${STAGE}.tpl >provision/inventory/${INVENTORY}
	@sed -e "s:PROJECT:${PROJECT}:g" -e "s:DOMAIN:${DOMAIN}:g" templates/cbsd.conf.tpl >cbsd.conf
	@sed -e "s:PROJECT:${PROJECT}:g" -e "s:DOMAIN:${DOMAIN}:g" templates/provision/group_vars/all.tpl >provision/group_vars/all

login:
	@sudo cbsd jlogin ${PROJECT}

exec:
	@sudo cbsd jexec jname=${PROJECT} ${command}

export: down
.if !exists(build)
	@mkdir build
.endif
	@echo -n "Exporting jail ... "
	@sudo cbsd jexport jname=${PROJECT}
	@sudo mv /cbsd/export/${PROJECT}.img build/
	@sudo chown ${UID}:${GID} build/${PROJECT}.img

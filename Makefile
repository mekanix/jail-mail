PROJECT=mail
INVENTORY=localhost

provision: up
	@sudo ansible-playbook -i provision/inventory/${INVENTORY} provision/site.yml

up: setup
	@sudo cbsd jcreate jconf=${PWD}/cbsd.conf || true
	@sudo sh -c 'sed -e "s:PWD:${PWD}:g" -e "s:PROJECT:${PROJECT}:g" templates/fstab.conf.tpl >/cbsd/jails-fstab/fstab.${PROJECT}'
	@sudo chown 1001:1001 cbsd.conf
	@sudo cbsd jstart ${PROJECT} || true

down: setup
	@sudo cbsd jstop ${PROJECT} || true
	@sudo ansible-playbook -i provision/inventory/${INVENTORY} provision/teardown.yml

destroy: down
	@rm -f provision/inventory/${INVENTORY} provision/site.yml provision/group_vars/all cbsd.conf
	@sudo cbsd jremove ${PROJECT}

setup:
	@sed -e "s:PROJECT:${PROJECT}:g" templates/cbsd.conf.tpl >cbsd.conf
	@sed -e "s:PROJECT:${PROJECT}:g" templates/provision/inventory.tpl >provision/inventory/${INVENTORY}
	@sed -e "s:PROJECT:${PROJECT}:g" templates/provision/group_vars/all.tpl >provision/group_vars/all
	@sed -e "s:PROJECT:${PROJECT}:g" templates/provision/site.yml.tpl >provision/site.yml

login:
	@sudo cbsd jlogin ${PROJECT}

exec:
	@sudo cbsd jexec jname=${PROJECT} ${command}

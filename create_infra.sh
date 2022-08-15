#!/bin/bash
cd infra/ansible
ansible-galaxy install -r requirements.yml
ansible-playbook playbooks/infra.yml

# Для дебага, поднятие инстанса с приложением
# cd ../../microservices/infra/
# ansible-galaxy install -r requirements.yml
# ansible-playbook playbooks/infra.yml
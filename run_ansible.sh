#!/bin/sh
ansible-playbook --connection=local -v --extra-vars "taskname=setting" ansible/playbook.yml
ansible-playbook --connection=local -v --extra-vars "taskname=dropbox" ansible/playbook.yml
ansible-playbook --connection=local -v --extra-vars "taskname=packages_option" ansible/playbook.yml

ansible-playbook --connection=local -v --extra-vars "taskname=caston" ansible/playbook.yml
ansible-playbook --connection=local -v --extra-vars "taskname=caston-load_data" ansible/playbook.yml

ansible-playbook --connection=local -v --extra-vars "taskname=finish_messages" ansible/playbook.yml

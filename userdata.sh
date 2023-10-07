#!/bin/bash

labauto ansible

ansible-pull -i localhost, -U https://github.com/sairm21/roboshop-ansible-v1 -e env=${var.env} -e role_name=${var.component} main.yml &>> /opt/ansible.log

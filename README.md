# Genesis-terraform-ansible-app
The repository is for Genesis DevOps School. 

### Description
The repo is for creating and configuring an infrastructure in the AWS cloud for the RESTful API application.  
Terraform creates: vpc, ec2 instance, RDS, ALB. Also, generate ssh_key, hosts and env files for Ansible.  
Ansible configures instance, copy files and run docker-compose.  

#### Requirements
There are packages below that should be installed on the (local) host where you'll be running deploy:
 * python >= 3.7
 * terraform >= 1.0.0
 * ansible >= 2.9
 * aws cli 

#### Supported OS
* Target linux instance should have Ubuntu >= 18 

### Terraform

The project is in [project_GENESIS](/terraform/project_GENESIS/)  

* [vpc_genesis](/terraform/modules/vpc_genesis/)                                    - the basic VPC module  
* [ansible_host.tpl](/terraform/project_GENESIS/templates/ansible_host.tpl)         - the hosts template for Ansible (ip, user, ssh_key)  
* [ansible_vars_alb.tpl](/terraform/project_GENESIS/templates/ansible_vars_alb.tpl)  - the ALB variables template for Ansible (ALB dns name for health check)  
* [env.tpl](/terraform/project_GENESIS/templates/env.tpl)                           - the env template for Ansible (db_host, db_name, db_user, db_pass ..)  
* [hostname.tpl](/terraform/project_GENESIS/templates/hostname.tpl)                 - the template for install host name  
* [genesis.auto.tfvars](/terraform/project_GENESIS/genesis.auto.tfvars)             - the overridden project variables  
* [alb.tf](/terraform/project_GENESIS/alb.tf)                                       - deploy ALB
* [ansible.tf](/terraform/project_GENESIS/ansible.tf)                               - create hosts, env, alb vars for ansible, and provisioner ansible in terraform (variable **ansible** = false is by default)
* [backend.tf](/terraform/project_GENESIS/backend.tf)                               - the backend file (s3)
* [data.tf](/terraform/project_GENESIS/data.tf)                                     - all data of project
* [ec2.tf](/terraform/project_GENESIS/ec2.tf)                                       - deploy EC2 instance
* [outputs.tf](/terraform/project_GENESIS/outputs.tf)                               - all outputs (ami, ec2, rds, alb)
* [provider.tf](/terraform/project_GENESIS/provider.tf)                             - the provider file
* [rds.tf](/terraform/project_GENESIS/rds.tf)                                       - deploy RDS
* [rsa_key.tf](/terraform/project_GENESIS/rsa_key.tf)                               - deploy ssh key and save in local host
* [security_group.tf](/terraform/project_GENESIS/security_group.tf)                 - deploy all security groups (for ec2, rds, alb)
* [variables.tf](/terraform/project_GENESIS/variables.tf)                           - all default variables
* [vpc.tf](/terraform/project_GENESIS/vpc.tf)                                       - deploy VPC


#### Directory tree - Terraform
```bash
├── modules
|   └── vps_genesis
|       ├── main.tf
|       ├── outputs.tf
|       └── variables.tf
|
└── project_GENESIS
  | └── templates
  |     ├── defaults
  |     ├── files
  |     ├── tasks
  |     └── checkapie.yml
  |
  ├── alb.tf
  ├── ansible.tf
  ├── backend.tf
  ├── data.tf
  ├── ec2.tf
  ├── genesis.auto.tfvars
  ├── outputs.tf
  ├── provider.tf
  ├── rds.tf
  ├── rsa_key.tf
  ├── security_group.tf
  ├── variables.tf
  └── vps.tf
```

### Ansible
The ansible playbooks for deploy the RESTful API application (run Docker Compose project in AWS instance).  
The Linux user that can be used by Ansible to access the host.  

The playbooks are in [playbooks](/ansible/playbooks/) subdirectory.  
The roles are in [roles](/ansible/roles/) subdirectory.  

* [genesis_app.yml](/ansible/playbooks/genesis_app.yml)                           - the playbook for deploing APP
* [app.yml](/ansible/roles/genesis_app/tasks/app.yml)                             - deploy RESTful API application: copy files and run docker-compose  
* [checkapi.yml](/ansible/roles/genesis_app/tasks/checkapi.yml)                   - health check
* [install_docker.yml](/ansible/roles/genesis_app/tasks/install_docker.yml)       - install docker and docker-compose in Ubuntu
* [ufw.yml](/ansible/roles/genesis_app/tasks/ufw.yml)                             - disable ufw in ubuntu  
* [main.yml](/ansible/roles/genesis_app/tasks/main.yml)                           - the main playbook with include all tasks  
* [docker-compose.j2](/ansible/roles/genesis_app/templates/docker-compose.j2)     - the template for docker-compose.yml  
* [main.yml](/ansible//roles/genesis_app/defaults/main.yml)                       - the variables for role
* [all.yaml](/ansible/inventory/group_vars/all/all.yaml)                           - the group variables.  
* [alb.yaml.example](/ansible/inventory/group_vars/all/alb.yaml.example)           - the variable with ALB dns name.  
* [host.ini.example](/ansible/inventory/hosts.ini.example)                         - the hosts file example.
* [files](/ansible/roles/genesis_app/files/.env.example)                          - the env file example.

#### Directory tree - Ansible
```bash
├── inventory
|   ├── group_vars
|   |   └── all
|   |        ├── all.yaml
|   |        └── alb.yaml.example
|   └── hosts.ini.example
|
├── playbooks
|   └── genesis_app.yml
|
├── roles
|   └── genesis_app
|       ├── defaults
|       |   └── main.yml
|       ├── files
|       |   └── .env.example
|       └── tasks
|       |   ├── checkapie.yml
|       |   ├── install_docker.yml
|       |   ├── main.yml
|       |   ├── ufw.yml
|       |   └── app.yml
|       └── templates
|            └── docker-compose.j2
└── ansible.cfg
```


#### Installation instructions to build the project

*1. Get source code for install project:*  
```
git clone https://github.com/spytliak/Genesis-terraform-ansible-app.git
```
*2. Go to the project folder `/terraform/project_GENESIS/` [project_GENESIS](/terraform/project_GENESIS/);*  
    *fill in all needed variables to [genesis.auto.tfvars](/terraform/project_GENESIS/genesis.auto.tfvars) for deploy;*  
    *check the backend and if use it, you should create backet for that:*  

*3. Deploy the infrastructure. For all deploy by terraform, please set variable "**ansible** = true":*
```
terraform init
terraform validate
terraform apply
```
*4. If don't need to deploy all, will go to ansible directory and install APP by Ansible:*
```
ansible-playbook -i inventory/hosts.ini playbooks/genesis_app.yml
```

### Outputs
Link to examples with full output for 2 methods: https://gist.github.com/spytliak/2fb0ae43ab963604fb27960b37a447a3

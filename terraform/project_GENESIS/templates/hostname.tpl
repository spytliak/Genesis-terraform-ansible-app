#cloud-config
manage_etc_hosts: false

runcmd:
  - sudo hostnamectl set-hostname ${hostname} 
  - sudo echo "$(hostname -I | awk '{print $1}') ${hostname}" >> /etc/hosts
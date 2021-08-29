#!/bin/bash
sudo apt-get update && sudo apt-get install python3-pip git -y
git clone https://github.com/kubernetes-sigs/kubespray
cd kubespray/
sudo pip3 install -r requirements.txt
cp -rfp inventory/sample inventory/mycluster
cp ../myhost.ini inventory/mycluster/
ansible-playbook -i inventory/mycluster/myhost.ini  --become --become-user=root cluster.yml
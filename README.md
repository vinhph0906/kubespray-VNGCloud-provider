# Create Kubernetes cluster with Terraform(VNGCloud provider) and Kubespray
## Introduction
### Terraform 
Terraform is an open-source created by HashiCorp. It allows users to define and provide their infrastructure through configuration language known as HashiCorp Configuration. This also calls infrastructure as code. More info: [https://www.terraform.io/](https://www.terraform.io/)

VNGCloud Provider is a plugin for Terraform that allows for the full lifecycle management of VNG Cloud resources. More info [https://registry.terraform.io/providers/vngcloud/vngcloud/latest/docs](https://registry.terraform.io/providers/vngcloud/vngcloud/latest/docs)

### Kubespray 
Kubespray is a composition of Ansible playbooks, inventory, provisioning tools, and domain knowledge for generic OS/Kubernetes clusters configuration management tasks. More info: [https://github.com/kubernetes-sigs/kubespray](https://github.com/kubernetes-sigs/kubespray)

## Prerequisites
`Terraform` must be installed
`GIT` and `python3-pip` will be install if not exits.
## How to Use
- Creating variables on file `varible.tf` which can get the template from file `variable.tf.example`.
- Init terrafrom by command `terrafrom init` then terraform will get VNGCloud provider from terraform registry.
- Apply your cluster by command `terrafrom apply`. Then terraform will show you overview about your infrastucture. 
- Finally, waitting the cluster create. 
## Connecting to your Kubernetes
- After finish file kube config will appear at `/root/.kube/config` in your master node. 
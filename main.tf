terraform {
  required_providers {
    vngcloud = {
      source = "vngcloud/vngcloud"
      version = "0.0.8"
    }
  }
}

provider "vngcloud" {
  token_url             = "https://monitoring-agent.vngcloud.vn/v1/intake/oauth2/token"
  client_id             = var.client_id
  client_secret         = var.client_secret
  project_id            = ""
  user_id               = ""
  vserver_base_url      = "https://vserverapi.vngcloud.vn/vserver-gateway"
}

data "vngcloud_vserver_flavor_zone" "flavor_zone" {
  name       = var.flavor_zone_name
  project_id = var.project_id
}
data "vngcloud_vserver_flavor" "flavor" {
  name           = var.flavor_name
  project_id     = var.project_id
  flavor_zone_id = data.vngcloud_vserver_flavor_zone.flavor_zone.id
}
data "vngcloud_vserver_image" "image" {
  name           = var.image_name
  project_id     = var.project_id
  flavor_zone_id = data.vngcloud_vserver_flavor_zone.flavor_zone.id
}
data "vngcloud_vserver_volume_type_zone" "volume_type_zone" {
  name       = "SSD"
  project_id = var.project_id
}
data "vngcloud_vserver_volume_type" "volume_type" {
  name                = var.volume_type_name
  project_id          = var.project_id
  volume_type_zone_id = data.vngcloud_vserver_volume_type_zone.volume_type_zone.id
}

resource "vngcloud_vserver_server" "k8s-master" {
    count               = var.master_count
    encryption_volume   = false
    flavor_id           = data.vngcloud_vserver_flavor.flavor.id
    image_id            = data.vngcloud_vserver_image.image.id
    name                = "kubernetes-${var.vng_cloud_cluster_name}-master-${count.index}"
    network_id          = var.network_id
    project_id          = var.project_id
    subnet_id           = var.subnet_id
    ssh_key             = var.ssh_key_id
    root_disk_size      = var.root_disk_size
    root_disk_type_id   = data.vngcloud_vserver_volume_type.volume_type.id
    attach_floating     = true
}

resource "vngcloud_vserver_server" "k8s-worker" {
    count               = var.worker_count
    encryption_volume   = false
    flavor_id           = data.vngcloud_vserver_flavor.flavor.id
    image_id            = data.vngcloud_vserver_image.image.id
    name                = "kubernetes-${var.vng_cloud_cluster_name}-worker-${count.index}"
    network_id          = var.network_id
    project_id          = var.project_id
    subnet_id           = var.subnet_id
    ssh_key             = var.ssh_key_id
    root_disk_size      = var.root_disk_size
    root_disk_type_id   = data.vngcloud_vserver_volume_type.volume_type.id
    attach_floating     = true
}

data "template_file" "inventory" {
  template = file("${path.module}/inventory.tpl")
  vars = {
    connection_strings_master    = join("\n", formatlist("%s ansible_host=%s", vngcloud_vserver_server.k8s-master[*].name, vngcloud_vserver_server.k8s-master[*].internal_interfaces[0].floating_ip))
    connection_strings_worker    = join("\n", formatlist("%s ansible_host=%s", vngcloud_vserver_server.k8s-worker[*].name, vngcloud_vserver_server.k8s-worker[*].internal_interfaces[0].floating_ip))
    list_master                  = join("\n", vngcloud_vserver_server.k8s-master[*].name)
    list_worker                  = join("\n", vngcloud_vserver_server.k8s-worker[*].name)
    ansible_port                 = var.ansible_port
    ansible_user                 = var.ansible_user
    ansible_ssh_private_key_file = var.ansible_ssh_private_key_file
  }
}

resource "null_resource" "inventories" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ${var.inventory_file}"
  }
  provisioner "local-exec" {
    command = "chmod u+x k8s-create-cluster.sh && ./k8s-create-cluster.sh"
  }
  triggers = {
    template = data.template_file.inventory.rendered
  }
}
[all]
${connection_strings_master}
${connection_strings_worker}

[kube_control_plane]
${list_master}

[kube_node]
${list_worker}

[etcd]
${list_master}

[calico_rr]

[k8s_cluster:children]
kube_node
kube_control_plane
calico_rr

[all:vars]
ansible_port=${ansible_port}
ansible_user=${ansible_user}
ansible_ssh_private_key_file=${ansible_ssh_private_key_file}
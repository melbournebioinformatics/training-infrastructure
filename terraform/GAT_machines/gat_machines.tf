locals {
  count = 35
  disk_size = 300 #GB
  flavor = "m3.medium" #4 core - 8GB RAM.

  instances = toset(formatlist("%d", range(local.count)))
  volumes = toset(flatten([ for instance in local.instances : "i${instance}-volume" ]))
  attachments = toset(flatten([ for instance in local.instances : {
      instance = instance
      volume = "i${instance}-volume"
    }]))
}

# Instances
resource "openstack_compute_instance_v2" "GAT-AU-instance" {
  for_each = local.instances
  name            = "GAT-AU-${each.value}"
  image_id        = "356ff1ed-5960-4ac2-96a1-0c0198e6a999"
  flavor_name     = local.flavor
  key_pair        = "gcc-2021"
  security_groups = ["SSH", "default"]
  availability_zone = "melbourne-qh2"
}


output "instance_ip_address" {
  value = {
    for instance in openstack_compute_instance_v2.GAT-AU-instance:
    instance.id => instance.access_ip_v4
  }
}


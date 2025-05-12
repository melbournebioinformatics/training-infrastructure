locals {
  count = 1
  flavor = "r3.xsmall" #1 core - 4GB RAM.
  label = "containers-tutorial"
  image_id = "b95c0ef8-9358-4bc7-b8fc-15500234794e" # ubuntu 22.04
  key_pair = "gvl-students"

  instances = toset(formatlist("%d", range(local.count)))
}

# Instances
resource "openstack_compute_instance_v2" "test-instance" {
  for_each = local.instances
  name            = "${local.label}-i${each.value}"
  image_id        = local.image_id
  flavor_name     = local.flavor
  key_pair        = local.key_pair
  security_groups = ["SSH", "default"]
  availability_zone = "melbourne-qh2"
}

output "instance_ip_address" {
  value = {
    for instance in openstack_compute_instance_v2.test-instance:
    instance.id => instance.access_ip_v4
  }
}

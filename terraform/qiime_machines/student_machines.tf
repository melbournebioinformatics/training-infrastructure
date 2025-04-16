locals {
  count = 0
  disk_size = 300 #GB
  flavor = "m3.xlarge" #16 core - 32GB RAM.
  label = "qiime"
  key_pair = "gvl-students"

  instances = toset(formatlist("%d", range(local.count)))
  # instances = toset(["0", "2", "3", "4"])  # refer to instances individually if needed
  volumes = toset(flatten([ for instance in local.instances : "i${instance}-volume" ]))
  attachments = toset(flatten([ for instance in local.instances : {
      instance = instance
      volume = "i${instance}-volume"
    }]))
}

# Instances
resource "openstack_compute_instance_v2" "test-instance" {
  for_each = local.instances
  name            = "${local.label}-i${each.value}"
  image_id        = "356ff1ed-5960-4ac2-96a1-0c0198e6a999"
  flavor_name     = local.flavor
  key_pair        = local.key_pair
  security_groups = ["SSH", "default"]
  availability_zone = "melbourne-qh2"
}

# Volumes
resource "openstack_blockstorage_volume_v3" "test-volume" {
  for_each = local.volumes
  availability_zone = "melbourne-qh2"
  name        = "${local.label}-i${each.value}-volume"
  description = "qiime tutorial VM volume"
  size        = local.disk_size
}

# Attachment between application/web server and volume
resource "openstack_compute_volume_attach_v2" "attach-dev-volume-to-dev" {
  for_each = { for idx in local.attachments: idx.instance => idx }
  instance_id = openstack_compute_instance_v2.test-instance[each.value.instance].id
  volume_id   = openstack_blockstorage_volume_v3.test-volume[each.value.volume].id
}

output "instance_ip_address" {
  value = {
    for instance in openstack_compute_instance_v2.test-instance:
    instance.id => instance.access_ip_v4
  }
}

# output "volume_attachment" {
#   value = {
#     for volume in openstack_blockstorage_volume_v2.test-volume:
#     volume.id => volume.attachments
#   }
# }


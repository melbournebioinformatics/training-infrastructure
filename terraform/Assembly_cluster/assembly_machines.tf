locals {
  count = 0
  disk_size = 1000 #GB
  flavour = "m3.xlarge"
  head_flavour = "m3.xlarge"

  instances = toset(formatlist("%d", range(local.count)))
  volumes = toset(flatten([ for instance in local.instances : "i${instance}-volume" ]))
  attachments = toset(flatten([ for instance in local.instances : {
      instance = instance
      volume = "i${instance}-volume"
    }]))
}

# Head Instance
resource "openstack_compute_instance_v2" "Ass-cluster-head" {
  name            = "Ass-cluster-head"
  image_id        = "356ff1ed-5960-4ac2-96a1-0c0198e6a999"
  flavor_name     = local.head_flavour
  key_pair        = "gvl-students"
  security_groups = ["SSH", "default"]
  availability_zone = "melbourne-qh2"
}

# Head Volume
resource "openstack_blockstorage_volume_v2" "Ass-cluster-head-volume" {
  availability_zone = "melbourne-qh2"
  name            = "Ass-cluster-head-volume"
  description     = "Assembly cluster head volume for NFS"
  size            = local.disk_size
}

# Head volume attachment
resource "openstack_compute_volume_attach_v2" "Ass-cluster-head-volume-attachment" {
  instance_id = "${openstack_compute_instance_v2.Ass-cluster-head.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.Ass-cluster-head-volume.id}"
}

# Worker Instances
resource "openstack_compute_instance_v2" "Ass-cluster-worker" {
  for_each = local.instances
  name            = "Ass-cluster-worker-${each.value}"
  image_id        = "356ff1ed-5960-4ac2-96a1-0c0198e6a999"
  flavor_name     = local.flavour
  key_pair        = "gvl-students"
  security_groups = ["SSH", "default"]
  availability_zone = "melbourne-qh2"
}



output "instance_ip_address" {
  value = {
    for instance in openstack_compute_instance_v2.Ass-cluster-worker:
    instance.id => instance.access_ip_v4
  }
}


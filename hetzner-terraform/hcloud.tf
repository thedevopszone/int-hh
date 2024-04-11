# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

### Server
resource "hcloud_server" "node1" {
  name        = "k8s-node1"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  datacenter  = "nbg1-dc3"
  ssh_keys    = [data.hcloud_ssh_key.ssh_key.name]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "node2" {
  name        = "k8s-node2"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  datacenter  = "nbg1-dc3"
  ssh_keys    = [data.hcloud_ssh_key.ssh_key.name]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "node3" {
  name        = "k8s-node3"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  datacenter  = "nbg1-dc3"
  ssh_keys    = [data.hcloud_ssh_key.ssh_key.name]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "node4" {
  name        = "k8s-node4"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  datacenter  = "nbg1-dc3"
  ssh_keys    = [data.hcloud_ssh_key.ssh_key.name]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "node5" {
  name        = "k8s-node5"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  datacenter  = "nbg1-dc3"
  ssh_keys    = [data.hcloud_ssh_key.ssh_key.name]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}


### Storage
resource "hcloud_volume" "storage-node1" {
  name       = "k8s-volume1"
  size       = 50
  server_id  = "${hcloud_server.node1.id}"
  automount  = true
  format     = "ext4"
}

resource "hcloud_volume" "storage-node2" {
  name       = "k8s-volume2"
  size       = 50
  server_id  = "${hcloud_server.node2.id}"
  automount  = true
  format     = "ext4"
}

resource "hcloud_volume" "storage-node3" {
  name       = "k8s-volume3"
  size       = 50
  server_id  = "${hcloud_server.node3.id}"
  automount  = true
  format     = "ext4"
}

resource "hcloud_volume" "storage-node4" {
  name       = "k8s-volume4"
  size       = 50
  server_id  = "${hcloud_server.node4.id}"
  automount  = true
  format     = "ext4"
}

resource "hcloud_volume" "storage-node5" {
  name       = "k8s-volume5"
  size       = 50
  server_id  = "${hcloud_server.node5.id}"
  automount  = true
  format     = "ext4"
}


data "hcloud_ssh_key" "ssh_key" {
  name = "macbook-pro"
}


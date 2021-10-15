locals {
  private_key = file("~/.ssh/mysshkey")
}

resource "digitalocean_ssh_key" "default" {
  name       = "leonardo"
  public_key = file("files/mysshkey.pub")
}

resource "digitalocean_droplet" "ot_node" {
  for_each = var.node_regions

  image    = "ubuntu-18-04-x64"
  name     = "node${index(var.node_regions, each.key)}"
  region   = each.key
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
  tags     = ["test"]

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y"]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = local.private_key
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${local.private_key} -e 'node_name=node${index(var.node_regions, each.key)}' node_setup.yml"
  }
}

output "ot_node_ips" {
  value = {for d in digitalocean_droplet.ot_node : d.name => d.ip4_address}
}
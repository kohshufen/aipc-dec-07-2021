data "digitalocean_ssh_key" "my-ssh-key" {
  name = "aipc-07-dec-2021"
}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-20-04-x64"
  name   = "aipc-08-dec-2021"
  region = "sgp1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.my-ssh-key.fingerprint]
}

resource local_file droplet_info {
    filename = "inventory.yaml"
    content = templatefile("inventory.yaml.tpl", {
        ipv4 = digitalocean_droplet.web.ipv4_address
    })
    file_permission = "0644"
}

output public_ip {
    value = digitalocean_droplet.web.ipv4_address
}

output my-ssh-key-fingerprint {
    value = data.digitalocean_ssh_key.my-ssh-key.fingerprint
}
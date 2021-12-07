data "digitalocean_ssh_key" "my-ssh-key" {
  name = "aipc-07-dec-2021"
}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-20-04-x64"
  name   = "web-1"
  region = "sgp1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.my-ssh-key.fingerprint]
  #ssh_keys = [digitalocean_ssh_key.local-key.fingerprint]

  //provisioner connection object
  connection {
      type = "ssh"
      user = "root"
      private_key = file("../../tmp/aipc-07-dec-2021")
      host = self.ipv4_address
  }

  provisioner remote-exec {
      inline = [
          "apt update -y",
          "apt upgrade -y",
          "apt install nginx -y",
          "systemctl enable nginx",
          "systemctl start nginx"
      ]
  }
}

output public_ip {
    value = digitalocean_droplet.web.ipv4_address
}


output my-ssh-key-fingerprint {
    value = data.digitalocean_ssh_key.my-ssh-key.fingerprint
}

# resource "digitalocean_ssh_key" local-key {
#     name = "my-local-key"
#     public_key = file("C://Users//shufe//OneDrive//Desktop//DigitalOcean//aipc-07-dec-2021")
# }

resource local_file "at_ipv4" {
    filename = "@${digitalocean_droplet.web.ipv4_address}"
    content = "${data.digitalocean_ssh_key.my-ssh-key.fingerprint}\n"
    file_permission = "0644"
}

resource local_file droplet_info {
    filename = "info.txt"
    content = templatefile("info.txt.tpl", {
        ipv4 = digitalocean_droplet.web.ipv4_address
        fingerprint = data.digitalocean_ssh_key.my-ssh-key.fingerprint    
    }) 
    file_permission = "0644"
}
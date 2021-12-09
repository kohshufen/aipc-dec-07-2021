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

  provisioner "file" {
      source = local_file.nginx-conf.filename #if put string terraform will not know this file need to be created first
      destination = "/etc/nginx/nginx.conf"
  }
  
  provisioner remote-exec {
      inline = [
           "nginx -s reload"
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

//docker
data docker_image dov-image {
    name = var.app_image
}

resource docker_container dov-container {
    count = var.app_count
    name = "dov-${count.index}"
    image = data.docker_image.dov-image.id
    ports {
        internal = 3000
    }
    env = ["INSTANCE_NAME=dov-${count.index}"]
}

output app-ports {
    value = flatten(docker_container.dov.contatiner[*].ports[*].external)
}

resource local_file nginx-conf {
    filename = "nginx.conf"
    file_permission = 0644 #read
    content = templatefile("nginx.conf.tpl", {
        docker_host = var.docker_host
        ports = flatten(docker_container.dov.contatiner[*].ports[*].external)
    })
}

// cloudflare
data cloudflare_zone myzone {
    name = var.CF_zone
    # A record use ip
    # CNAME use domain
}

resource cloudflare_record a-dov {
    zone_id = data.cloudflare_zone.myzone.zone_id
    name = "dov"
    type = "A"
    value = digitalocean_droplet.web.ipv4_address
    proxied = true
}

## generate graph
#terraform graph > resource-dep.dot
#dot -Tpng 
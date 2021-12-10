// Private key
data digitalocean_ssh_key my-key {
    name = "aipc-07-dec-2021" # The name of the public key created in DO > Settings > Security
}

// Create 3 dockers
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
    env = [ "INSTANCE_NAME=dov-${count.index}" ]
}

// Templating
resource local_file nginx-conf {
    filename = "nginx.conf"
    content = templatefile("nginx.conf.tpl", {
        docker_host = var.docker_host
        ports = flatten(docker_container.dov-container[*].ports[*].external)
    })
    file_permission = "0644"
}

resource local_file "at_ipv4" {
    filename = "@${digitalocean_droplet.my-droplet.ipv4_address}"
    content = "${data.digitalocean_ssh_key.my-key.fingerprint}\n"
    file_permission = "0644"
}

resource local_file droplet_info {
    filename = "info.txt"
    content = templatefile("info.txt.tpl", {
        ipv4 = digitalocean_droplet.my-droplet.ipv4_address
        fingerprint = data.digitalocean_ssh_key.my-key.fingerprint
    })
    file_permission = "0644"
}

// Server - Nginx
resource digitalocean_droplet my-droplet {
    name = "my-droplet"
    image = var.DO_image
    size = var.DO_size
    region = var.DO_region
    ssh_keys = [ data.digitalocean_ssh_key.my-key.fingerprint ]

    // provisioner connection object
    connection {
        type = "ssh"
        user = "root"
        private_key = file(var.private_key)
        host = self.ipv4_address
    }

    // install nginx
    provisioner remote-exec {
        inline = [
            "apt update -y",
            "apt upgrade -y",
            "apt install nginx -y",
            "systemctl enable nginx",
            "systemctl start nginx",
        ]
    }

    // copy nginx.conf to server
    provisioner file {
        source = local_file.nginx-conf.filename
        destination = "/etc/nginx/nginx.conf"
    }

    // reload nginx
    provisioner remote-exec {
        inline = [
            "nginx -s reload"
        ]
    }
}
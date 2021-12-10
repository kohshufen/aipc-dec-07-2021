// Private key
data digitalocean_ssh_key my-key {
    name = "aipc-07-dec-2021" # The name of the public key created in DO > Settings > Security
}

data digitalocean_image code-server {
    name = "my-code-server"
}

// set up server using golden image
resource digitalocean_droplet setup-droplet {
    name = "code-server-droplet"
    image = data.digitalocean_image.code-server.id
    size = var.DO_size
    region = var.DO_region
    ssh_keys = [ data.digitalocean_ssh_key.my-key.fingerprint ]
}

resource local_file inventory {
    filename = "inventory.yaml"
    file_permission = 0644
    content = templatefile("inventory.yaml.tpl", {
        host_name = digitalocean_droplet.setup-droplet.name
        ipv4 = digitalocean_droplet.setup-droplet.ipv4_address
        private_key = var.private_key
        public_key = var.public_key
        cs_password = var.cs_password
    })
}
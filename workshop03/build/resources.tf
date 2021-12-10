// Private key
data digitalocean_ssh_key my-key {
    name = "aipc-07-dec-2021" # The name of the public key created in DO > Settings > Security
}

// Create server
resource digitalocean_droplet web {
    name = "my-droplet"
    image = var.DO_image
    size = var.DO_size
    region = var.DO_region
    ssh_keys = [ data.digitalocean_ssh_key.my-key.fingerprint ]
}

// Templating - ansible inventory.yaml
resource local_file droplet_info {
    filename = "inventory.yaml"
    content = templatefile("inventory.yaml.tpl", {
        ipv4 = digitalocean_droplet.web.ipv4_address
        private_key = var.private_key
        public_key = var.public_key
    })
    file_permission = "0644"
}
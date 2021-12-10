output ipv4 {
    value = digitalocean_droplet.my-droplet.ipv4_address
}

output my-key-fingerprint {
    value = data.digitalocean_ssh_key.my-key.fingerprint
}

output app-ports {
    value = flatten(docker_container.dov-container[*].ports[*].external)
}
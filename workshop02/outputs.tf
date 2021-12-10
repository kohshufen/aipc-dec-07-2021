output public_ip {
    value = digitalocean_droplet.web.ipv4_address
}

output my-ssh-key-fingerprint {
    value = data.digitalocean_ssh_key.my-key.fingerprint
}
packer {
    required_plugins {
        digitalocean = {
            source = "github.com/hashicorp/digitalocean"
            version = ">= 1.0.0"
        }
    }
}    
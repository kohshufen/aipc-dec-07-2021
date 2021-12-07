resource docker_image container-image {
    count = length(var.containers) # because we have count, this resource become an array
    name = var.containers[count.index].imageName
    keep_locally = var.containers[count.index].keepImage
    #name = "stackupiss/dov-bear:${var.version}"
}

resource docker_container container-app {
    count = length(var.containers)
    name = var.containers[count.index].containerName
    image = docker_image.container-image[count.index].latest
    ports {
       internal = var.containers[count.index].containerPort
       #external = var.containers[count.index].externalPort
    }
    env = var.containers[count.index].envVariables
}

# each time you change the resource, need to terraform apply
output port0 {
    #value = docker_container.container-app
    #value = docker_container.container-app[0].ports
    value = docker_container.container-app[0].ports[0].external
}
output port1 {
    #value = docker_container.container-app
    #value = docker_container.container-app[1].ports
    value = docker_container.container-app[1].ports[0].external
}

# output all into one list
output externalPorts {
    # value = docker_container.container-app[*].ports[*].external
    value = flatten(docker_container.container-app[*].ports[*].external)
    sensitive = true # terraform will not display the value if data is sensitive
}

# resource docker_image fortune {
#     name = "stackupiss/fortune:v2"
#     keep_locally = true
# }

# resource docker_container dov-app {
#     name = var.name
#     image = docker_image.dov-bear.latest
#     ports {
#         internal = 3000
#         external = 8080
#     }
#     #env = [
#     #    "INSTANCE_NAME=dov-app", 
#     #    "INSTANCE_HASH=abc123"
#     #] 
# }

# resource docker_container fortune-app {
#     name = "app1"
#     image = docker_image.fortune.latest
#     ports {
#         internal = 3000
#         external = 8081
#     }
# }
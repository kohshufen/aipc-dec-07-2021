# variable tag_version {
#   type = string
#   default = "v2"
# }

# variable keep_image {
#     type = bool
#     default = true
# }

# variable name {
#     type = string # put in a value when it runs
# }

# variable DO_token {
#     type = string # put in a value when it runs
#     sensitive = true
# }

variable containers {
    type = list(object({
        imageName = string
        containerName = string
        containerPort = number
        externalPort = number
        envVariables = list(string)
        keepImage = bool
    }))

    default = [
        {
          imageName = "stackupiss/dov-bear:v2"
          containerName = "dov-bear"
          containerPort = 3000
          externalPort = 8080  
          envVariables = ["INSTANCE_NAME=dov-app", "INSTANCE_HASH=abc123"]
          keepImage = true
        },
        {
          imageName = "stackupiss/fortune:v2"
          containerName = "fortune"
          containerPort = 3000
          externalPort = 8081  
          envVariables = []
          keepImage = true
        }
    ]

}    
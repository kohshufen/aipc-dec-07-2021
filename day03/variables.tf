variable do_token {
  type = string
  sensitive = true
}
variable app_image {
    type = string 
    default = "stackupiss/dov-bear:v2"
}

variable app_count {
    type = number 
    default = 3
}
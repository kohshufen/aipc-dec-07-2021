all:
  hosts:
    myserver:
      ansible_host: ${ipv4}
      ansible_user: root
      ansible_connection: ssh
      ansible_private_key_file: ${private_key}
      public_key_file: ${public_key}
      cs_password: ${cs_password}
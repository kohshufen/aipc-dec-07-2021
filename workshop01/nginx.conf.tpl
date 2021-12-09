user www-data;
worker_processes auto;
pid /run/nginx.pid;
events {
    worker_connections 768;
}
http {
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    gzip on;
    upstream apps {
        least_conn;
        # the following list the container endpoints
        # one server line for each endpoint
        # eg server <docker_host_ip>:<exposed_port>;
        %{ for p in ports ~}   #spacing is not impt. in python, yaml, the spacing matters
        server ${docker_host}:${p};
        %{ endfor }
       
    }
    server {
        listen 80;
        location / {
            proxy_pass http://apps;
        }
    }
}
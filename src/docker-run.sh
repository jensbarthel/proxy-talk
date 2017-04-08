#!/bin/bash
echo "Starting nginx instance..."
docker run -d -p 80:80 -p 443:443 \
    --name nginx \
    -v /etc/nginx/conf.d  \
    -v /etc/nginx/vhost.d \
    -v /usr/share/nginx/html \
    -v /home/core/certs:/etc/nginx/certs:ro \
    nginx

sleep 1
echo "Starting docker-gen instance..."
docker run -d \
  --name nginx-gen \
  --volumes-from nginx \
  -v /home/core/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  jwilder/docker-gen \
  -notify-sighup nginx -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

sleep 1
echo "Starting letsencrypt-nginx-proxy-companion..."
docker run -d \
  --name nginx-letsencrypt \
  -e "NGINX_DOCKER_GEN_CONTAINER=nginx-gen" \
  --volumes-from nginx \
  -v /home/core/certs:/etc/nginx/certs:rw \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  jrcs/letsencrypt-nginx-proxy-companion

sleep 1
echo "Starting sigdevops example app..."
docker run -d \
    --name sigdevops-app \
    -e "VIRTUAL_HOST=sigdevops.io" \
    -e "LETSENCRYPT_HOST=sigdevops.io" \
    -e "LETSENCRYPT_EMAIL=jb@wps.de" \
    nginx

sleep 1
echo "Starting sigdevops docker registry..."
docker run -d \
    --name sigdevops-registry \
    -e "VIRTUAL_HOST=registry.sigdevops.io" \
    -e "LETSENCRYPT_HOST=registry.sigdevops.io" \
    -e "LETSENCRYPT_EMAIL=jb@wps.de" \
    registry

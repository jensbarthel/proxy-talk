#!/bin/bash
echo "Building proxy talk nginx..."
wget https://github.com/jensbarthel/proxy-talk/archive/master.zip
unzip master.zip
rm master.zip
cd proxy-talk-master
docker build -t registry.sigdevops.io/talk-nginx .
echo "Pushing proxy talk nginx..."
docker push registry.sigdevops.io/talk-nginx

echo "Starting proxy talk nginx..."
docker run -d \
    --name sigdevops-talk \
    -e "VIRTUAL_HOST=talk.sigdevops.io" \
    -e "LETSENCRYPT_HOST=talk.sigdevops.io" \
    -e "LETSENCRYPT_EMAIL=jb@wps.de" \
    registry.sigdevops.io/talk-nginx

FROM nginx
COPY index.html /usr/share/nginx/html
COPY css /usr/share/nginx/html/css
COPY img /usr/share/nginx/html/img
COPY js /usr/share/nginx/html/js
COPY lib /usr/share/nginx/html/lib
COPY plugin /usr/share/nginx/html/plugin

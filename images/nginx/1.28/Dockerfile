FROM nginx:1.28
MAINTAINER Ivan Koliadynskyi <i.koliadynskyi@gmail.com>

USER root

ARG APP_ID=1000
RUN groupmod --gid "$APP_ID" www-data \
  && usermod -g "$APP_ID" -u "$APP_ID" -d /var/www -s /bin/bash www-data
RUN touch /var/run/nginx.pid

RUN rm -rf /etc/nginx/certs
RUN rm -rf /sock

RUN mkdir /sock

RUN apt update && apt install -y \
  sudo \
  curl \
  nano \
  openssl \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/user  nginx;//' /etc/nginx/nginx.conf
RUN sed -i -e 's/worker_processes 2;/worker_processes  4;/' /etc/nginx/nginx.conf
RUN sed -i -e '/#gzip  on;/i \
    client_max_body_size 50m;\n \
    gzip on;\n \
    gzip_disable msie6;\n \
    gzip_vary on;\n \
    gzip_proxied any;\n \
    gzip_comp_level 6;\n \
    gzip_buffers 16 8k;\n \
    server_tokens off;\n \
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript;' /etc/nginx/nginx.conf

RUN usermod -aG sudo www-data
RUN usermod -aG adm www-data
RUN echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN rm -rf /etc/nginx/certs

RUN mkdir /etc/nginx/certs \
  && echo -e "\n\n\n\n\n\n\n" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/selfsigned.key -out /etc/nginx/selfsigned.crt

ARG TARGETARCH

RUN cd /usr/local/bin/ \
  && curl -L https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-$TARGETARCH -o mkcert \
  && chmod +x mkcert

RUN mkdir -p /etc/nginx/html /var/www \
  && chown -R www-data:www-data /etc/nginx /var/www /var/cache/nginx /var/log /var/run/nginx.pid /sock

EXPOSE 80 443

VOLUME /var/www
WORKDIR /var/www
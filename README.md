# docker-dev-env

Docker compose configuration and images for local development.
Originally built for Magento 2 / Adobe Commerce, but usable for other PHP projects.
Tested on Ubuntu 22.04.

## Requirements
- Docker Engine + Compose plugin
- mkcert (installed by `./bin/init.sh`)
- Linux (Windows/macOS may work with manual adjustments)

## HTTPS quick start (recommended)
1. Make scripts executable:
```
chmod +x ./bin/init.sh ./bin/add-domain.sh
```
2. Install mkcert and generate local certs (run as your normal user):
```
./bin/init.sh
```
3. Start containers:
```
docker compose up -d
```
4. Open `https://example.localhost`

Optional: add a custom domain with HTTPS:
```
./bin/add-domain.sh appname.localhost
```

## What init.sh does
- Installs `mkcert` and `libnss3-tools`
- Trusts the mkcert local CA for the current user
- Generates `conf/ssl/dev.pem` and `conf/ssl/dev-key.pem` for `localhost`, `*.localhost`, and `*.dev.localhost`

Note: Do not run `./bin/init.sh` with `sudo`. If you did, re-run `mkcert -install` as your normal user.

## Certificates and nginx
- `conf/ssl/dev.pem` and `conf/ssl/dev-key.pem` are mounted into nginx as `/etc/nginx/ssl/dev.pem` and `/etc/nginx/ssl/dev-key.pem`.
- Nginx includes them via `conf/nginx/snippets/ssl.conf`.
- To use the default dev certificate in your vhost, add IPv6 listeners (required for dual-stack):
```
listen 80;
listen [::]:80;
listen 443 ssl;
listen [::]:443 ssl;
include /etc/nginx/snippets/ssl.conf;
```

## How to add a new app (Method 1 - Recommended)
1. Put your app under `www/your-app`
2. Use a domain ending in `.dev.localhost` (e.g. `reisebank.dev.localhost`)
3. Add an nginx vhost in `conf/nginx/conf.d/` (use `conf/nginx/conf.d/example.conf` as a template)
4. Restart nginx:
```
docker compose restart nginx
```
**No host entry or certificate generation is needed** for `.dev.localhost` domains.

## How to add a new app (Method 2 - Custom Domain)
1. Put your app under `www/your-app`
2. Add a host entry for non-`.localhost` domains (Linux example):
```
127.0.0.1 your-app.localhost
```
3. Run: `./bin/add-domain.sh appname.test`
4. Add an nginx vhost in `conf/nginx/conf.d/`
5. Restart nginx

## Services and ports
- nginx: `80`, `443`
- MariaDB: `3306`
- phpMyAdmin: `8080`
- Redis: internal only
- RabbitMQ Management: `8082`
- Elasticsearch 7: `9201`
- OpenSearch: `9200`, `9300`

## phpMyAdmin login
- Host: `mysql`
- User: `admin` (password from `docker-compose.yml`)
- Root: `root` (password from `docker-compose.yml`)

If you need database creation privileges for `admin`, use `root` to grant them.

## Common commands
Start:
```
docker compose up -d
```
Stop:
```
docker compose down
```
Restart nginx:
```
docker compose restart nginx
```

## HTTPS troubleshooting
If the browser shows an untrusted cert warning:
```
mkcert -install
mkcert -cert-file conf/ssl/dev.pem -key-file conf/ssl/dev-key.pem example.localhost localhost "*.localhost"
docker compose restart nginx
```
Then fully restart the browser.

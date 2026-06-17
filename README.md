# docker-dev-env

Docker compose configuration and images for local development.
Originally built for Magento 2 / Adobe Commerce, but usable for other PHP projects.
The default stack targets **Adobe Commerce 2.4.9** system requirements.
Tested on Ubuntu 22.04.

## Requirements
- Docker Engine + Compose plugin
- mkcert (installed by `./bin/init.sh`)
- Linux (Windows/macOS may work with manual adjustments)

## Stack versions (Adobe Commerce 2.4.9)
| Service | Version | Notes |
|---|---|---|
| PHP | 8.3 / 8.4 / **8.5** | 8.5 required by 2.4.9; all built from `images/php/*` |
| nginx | 1.30 | built from `images/nginx/1.30` |
| MariaDB | 12.3 | MySQL 8.4 is the supported alternative |
| OpenSearch | 3 | search engine for 2.4.9 |
| Valkey | 9 | cache / session backend for 2.4.9 |
| RabbitMQ | 4.2 | message queue (management UI) |
| Elasticsearch | 7.17 | legacy only — kept for older projects |
| Redis | latest | legacy only — Valkey is the 2.4.9 default |

The PHP and nginx images are published to Docker Hub under `ivankodev/*` and are
pulled by default in `docker-compose.yml`. The matching `Dockerfile`s live under
`images/` so they can also be built locally (uncomment the `build:` line for any
service to build instead of pull).

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
- Valkey: internal only
- Redis (legacy): internal only
- RabbitMQ Management: `8082`
- Elasticsearch 7 (legacy): `9201`
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

## Building and publishing images
The PHP and nginx images are pulled from Docker Hub by default. To rebuild and
publish them (e.g. after changing a `Dockerfile`):
```
docker build -t ivankodev/php:8.5 ./images/php/8.5
docker push ivankodev/php:8.5
```
Repeat for `8.3`, `8.4` and `ivankodev/nginx:1.30`. To build locally without
publishing, just uncomment the `build:` line of the service in `docker-compose.yml`.

## HTTPS troubleshooting
If the browser shows an untrusted cert warning:
```
mkcert -install
mkcert -cert-file conf/ssl/dev.pem -key-file conf/ssl/dev-key.pem example.localhost localhost "*.localhost"
docker compose restart nginx
```
Then fully restart the browser.

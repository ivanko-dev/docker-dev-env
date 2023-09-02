# docker-dev-env


Docker compose configuration and images for local development.
In general developed for Magento 2 / Adobe Commerce development but easy may be used for other PHP based projects.

Package developed for Linux type OS and tested with Ubuntu 22.04.

## How to use
1. Install docker
```
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
2. Configure docker to run on start up
```
sudo systemctl enable docker
sudo systemctl start docker
```
3. Add user to docker group for correct launching and access (replace _**yourusername**_ with your real username in the system)
```
sudo usermod -aG docker yourusername
```
4. Add required nginx configuration to `conf/nginx` folder in package and register used local domain in your OS `/etc/hosts`
5. Open cloned repository root folder (where docker-compose.yml placed) and start docker:
```
docker compose up -d
```

## How to add new application to dev environment
1. Place files for application into installed package `www` directory
2. Choose local domain for application and add it to hosts configuration (eg. `/etc/hosts` on Ubuntu or `C:\Windows\System32\drivers\etc\hosts` on Windows)
    ```
    ## EXAMPLE FOR http://example.local ##
   127.0.0.1       example.local www.example.local
   ```
3. Create nginx config for application in the `conf/nginx` package folder (check `cong/nginx/example.conf` for details)
   1. specify the root folder using path inside of container. For example if your have application in `www/example` then `root /var/www/example;` should be specified in config
   2. configure required version of PHP for FastCGI server (`fastcgi_pass`) using container name and default PHP port.
   For example for PHP 8.1 this will be `fastcgi_pass php81:9000`. You can use `upstream` config for this purpose, for example:
   ```
   upstream fastcgi_backend_exmp {
       server  php82:9000;
   }
   ....
       location ~ ^/.+\.php(/|$) {
           fastcgi_pass   fastcgi_backend_exmp;
           ....
   ```
4. Restart nginx container and application should be accessible using previously defined local domain
   ```
   docker container restart nginx
   ```

## TODO List
- prepare more detailed documentation and description (_80% done_)
- test prepared images and compose configuration (_70% done_)
- include additional services/images in package
- ~~create SH script for automatic deployment and configuration~~ (_deprecated as not needed for dev env_)

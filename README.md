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

## TODO List
- prepare detailed documentation and description
- test prepared images and compose configuration
- include additional services/images in package
- create SH script for automatic deployment and configuration

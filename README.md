# lyrishq-deploy
Lyris HQ setup and deployment scripts

### Usage
To generate a self-installer script use: `./build.sh` and then execute the generated script: `./lyrishq-installer.bsx`

The script accepts an optional parameter indicating the installation directory for the lyrishq repository.

### Helper scripts
1. install-docker.sh: Installs **docker** and **docker-compose** programs (for Ubuntu)
2. test-lhq-api.sh: Tests the API endpoints (it requires HTTPie, to install use `apt install httpie`)

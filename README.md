# lyrishq-deploy
Lyris HQ setup and deployment scripts.

Main installer script: [payload/installer.sh](payload/installer.sh)

### Usage
To generate a self-installer script use: `./build.sh` and then execute the generated script: `./lyrishq-installer.bsx`

The script accepts an optional parameter indicating the installation directory for the lyrishq repository.

```
ubuntu@ip-10-66-25-89:~/deploy$ ./build.sh 
Build started.
Self-installer file created: lyrishq-installer.bsx
ubuntu@ip-10-66-25-89:~/deploy$ ./lyrishq-installer.bsx /home/ubuntu

Self Extracting Installer

Installation directory: /home/ubuntu

*** SETTING UP AND DEPLOYING Lyris HQ ***
 - Docker is installed
 - Docker compose is installed
 - Git is installed
 - HTTPie is installed
 - emaillabs.ec2.internal is configured in /etc/hosts
 - Cloning repositories:
   - aurea-lyris-hq-dev-docker
 - Updating submodules
Synchronizing submodule url for 'emaillabs/app/src'
Synchronizing submodule url for 'emaillabs/front-end/src'
Synchronizing submodule url for 'emservices/app/src'
Synchronizing submodule url for 'lyris-hq/authorization-flex/src'
Synchronizing submodule url for 'lyris-hq/authorization/src'
Synchronizing submodule url for 'lyris-hq/hq-themes/src'
Synchronizing submodule url for 'lyris-hq/hq-uih-themes/src'
Synchronizing submodule url for 'lyris-hq/library/src'
Synchronizing submodule url for 'mcwf/app/src'
Synchronizing submodule url for 'mcwf/ckeditor/src'
 - Extracting payload files...
emaillabs/database/files/
emaillabs/database/files/config/
emaillabs/database/files/config/custom.cnf
emaillabs/database/files/scripts/
emaillabs/database/files/scripts/create-platform-databases.sh
 - Fixing docker-compose.yml labels
 - Updating docker-compose.yml MySQL volume and port
 - Setting up HTTP port for web container
 - Building emaillabs containers
lyrishq_database_1 is up-to-date
lyrishq_consul_1 is up-to-date
lyrishq_mailhog_1 is up-to-date
lyrishq_registrator_1 is up-to-date
lyrishq_mail-control_1 is up-to-date
lyrishq_mail-processing_1 is up-to-date
lyrishq_mail-out_1 is up-to-date
lyrishq_mail-in_1 is up-to-date
Starting lyrishq_traefik_1 ...
Starting lyrishq_traefik_1 ... done
lyrishq_web_1 is up-to-date
SUCCESS!!
1. MySQL is running locally, use 'mysql -uroot -pdevdev -h 127.0.0.1 uptilt_db'                                                                           
2. Emaillabs web interface is running locally, use 'http :/' if you have HTTPie installed                                                                 

-- Installation finished --

ubuntu@ip-10-66-25-89:~/deploy$

```

### Helper scripts
1. [install-docker.sh](helpers/install-docker.sh): Installs **docker** and **docker-compose** programs (for Ubuntu)
2. [test-lhq-api.sh](helpers/test-lhq-api.sh): Tests the API endpoints (it requires **HTTPie**, to install use `apt install httpie`)
3. [build-ems.sh](helpers/build-ems.sh): Builds **emservices** and **lyrishq-web** docker containers.
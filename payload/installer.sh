#!/bin/sh

# file: installer.sh
# author: @wgxo

# Setup and installation script for Lyris HQ
 
# COLORS
BROWN="\033[0;33m"; BLUE="\033[1;34m"; RED="\033[0;31m"; LIGHT_RED="\033[1;31m"; PURPLE="\033[1;35m"
GREEN="\033[1;32m"; WHITE="\033[1;37m"; LIGHT_GRAY="\033[0;37m"; YELLOW="\033[1;33m"; CYAN="\033[1;36m"
NOCOLOR="\033[0m"

die() {
    echo "${RED}ERROR: $@. Exiting.${NOCOLOR}"
    exit 1
}

green()  echo "${GREEN}$@${NOCOLOR}"
out()    echo "${BROWN}$@${NOCOLOR}"
blue()   echo "${BLUE}$@${NOCOLOR}"
yellow() echo "${YELLOW}$@${NOCOLOR}"
purple() echo "${PURPLE}$@${NOCOLOR}"
cyan()   echo "${CYAN}$@${NOCOLOR}"
red()    echo "${LIGHT_RED}$@${NOCOLOR}"

blue "*** SETTING UP AND DEPLOYING Lyris HQ ***"

# Get installation directory
if [ $# -eq 0 ]; then CURDIR=$HOME; else CURDIR=$1; fi
[ -d $CURDIR ] || die "Installation directory not found"

TEMP_DIR=`pwd`
# Move to installation directory
cd $CURDIR

(command -v docker >/dev/null 2>&1 && out " - Docker is installed") || die "Docker is not installed!"
(command -v docker-compose >/dev/null 2>&1 && out " - Docker compose is installed") || die "Docker Compose is not installed!"
(command -v git >/dev/null 2>&1 && out " - Git is installed") || die "Git is not installed!"
(command -v http >/dev/null 2>&1 && out " - HTTPie is installed") || purple "HTTPie is not installed!"

[ -z $(id|grep -Poe docker) ] && die "User does not belong to docker group"

if [ -z $(grep -Poe '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?=.*emaillabs.ec2.internal)' /etc/hosts) ]; then
    out " - Setting up hosts file"
    sudo bash -c 'echo "127.0.0.1 emaillabs.ec2.internal nexus.ec2.internal mailhog.ec2.internal mcwf.ec2.internal lhq.ec2.internal emservices.ec2.internal" >> /etc/hosts'
else
    out " - emaillabs.ec2.internal is configured in /etc/hosts"
fi

out    " - Cloning repositories:"

purple "   - aurea-lyris-hq-dev-docker"
[ -d lyrishq/.git ] || git clone git@github.com:trilogy-group/aurea-lyris-hq-dev-docker lyrishq >/dev/null || die "Cannot clone repository"

cd lyrishq

out " - Updating submodules"
perl -pi -e 's[https://github.com/trilogy-group][git\@github.com:trilogy-group]' .gitmodules
[ -d emaillabs/app/src/.git ] || (git submodule sync && git submodule update --init --remote --checkout --recursive) || die "Cannot initialize submodules"

out " - Extracting payload files..."
tar xvf $TEMP_DIR/files.tar

DOCKERFILE="emaillabs/database/Dockerfile"
[ -f $DOCKERFILE ] || die "Database Dockerfile not found"

if [ -z "`grep -Poe 'COPY ./files/config' $DOCKERFILE`" ]; then
		out " - Updating database Dockerfile"
		echo "COPY ./files/scripts /docker-entrypoint-initdb.d/" >> $DOCKERFILE
		echo "COPY ./files/config  /etc/mysql/conf.d/" >> $DOCKERFILE
fi

out " - Fixing docker-compose.yml labels"
perl -pi -e 's[- "(SERVICE_\d+(_\w+)+?)=(.+)"$][\1: "\3"]' docker-compose.yml
perl -pi -e 's[- (SERVICE_\d+(_\w+)+?)=(.+)$][\1: "\3"]' docker-compose.yml

out " - Updating docker-compose.yml MySQL volume and port"
sed -i 's/- "3306"/- "3306:3306"/' docker-compose.yml
sed -i '/- "3306:3306"/a\    volumes:\n      - database:/var/lib/mysql\n' docker-compose.yml 
sed -i '/nexus-data:$/a\  database:\n' docker-compose.yml 

out " - Setting up HTTP port for web container"
sed -i 's/- "80:80"/- "80"/' docker-compose.yml 
sed -i '/http:\/\/web:8080/{N;N;N;N;N;N;N;N;s/- "8080"/- "80:8080"/;}' docker-compose.yml 

out " - Building emaillabs containers"
docker-compose up -d web mail-control mail-out mail-in mail-processing || die Docker-compose failed

green "SUCCESS!!"

cyan "1. MySQL is running locally, use 'mysql -uroot -pdevdev -h 127.0.0.1 uptilt_db'"
cyan "2. Emaillabs web interface is running locally, use 'http :/' if you have HTTPie installed"

echo ""
red "-- Installation finished --"
echo ""

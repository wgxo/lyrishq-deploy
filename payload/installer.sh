#!/bin/sh

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
[ -f emaillabs/app/src/.git ] || (git submodule sync && git submodule update --recursive) || die "Cannot initialize submodules"

out " - Extracting payload files..."
tar xvf $TEMP_DIR/files.tar

DOCKERFILE="emaillabs/database/Dockerfile"
[ -f $DOCKERFILE ] || die "Database Dockerfile not found"

if [ -z "`grep -Poe 'COPY ./files/config' $DOCKERFILE`" ]; then
		out " - Updating database Dockerfile"
		echo "COPY ./files/scripts /docker-entrypoint-initdb.d/" >> $DOCKERFILE
		echo "COPY ./files/config  /etc/mysql/conf.d/" >> $DOCKERFILE
fi

exit

cd ../aladdin

out " - Fixing brewfictus hostname"
grep -rl brewfictus.kayako.com ../* 2>/dev/null | while read f; do
    perl -pi -e 's[brewfictus.kayako.com][brewfictus.kayako.com]' $f
done

out " - Copying config files"
cp -fva configs/novo-api/* ../novo-api/__config/ | sed -e 's/^.*\///' -e "s/'//" 

out " - Creating .env file"
cat <<EOF > .env
CODE_PATH=../novo-api
# here to stop docker complaining that the variable is not set
BLACKFIRE_CLIENT_ID=
BLACKFIRE_CLIENT_TOKEN=
BLACKFIRE_SERVER_ID=
BLACKFIRE_SERVER_TOKEN=
EOF

out " - Updating docker-compose file"
perl -pi -e 's[context: ../kayako-realtime-engine][context: ../realtime-engine]' docker-compose.yml
perl -pi -e 's[context: ../relay][context: ../novo-relay]' docker-compose.yml

out " - Updating php container reference in site.conf"
perl -pi -e 's[php5:9000][php:9000]' web/site.conf

out " - Building web container"
docker-compose up -d --build web || die "Cannot start web container"

out " - Rebuilding database"
docker-compose exec -T db mysql -u root -pOGYxYmI1OTUzZmM -e 'drop database if exists `brewfictus.kayako.com`; create database `brewfictus.kayako.com`;' || die "Cannot setup database"
docker-compose exec -T redis ash -c 'redis-cli flushall' || die "Cannot flush redis"

out " - Setting up TNK"
docker-compose exec -T php bash -c 'cd /var/www/html/product/setup && php console.setup.php "Brewfictus" "brewfictus.kayako.com" "Brewfictus" "admin@kayako.com" "setup"' || die "Cannot setup TNK"

green "SUCCESS!!"

echo "-- Installation finished --"
echo

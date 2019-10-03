#!/bin/sh

# file: build-ems.sh
# author: @wgxo

# This script configures and builds the docker containers for lyrishq-web and emservices

# COLORS
BROWN="\033[0;33m"; BLUE="\033[1;34m"; RED="\033[0;31m"; LIGHT_RED="\033[1;31m"; PURPLE="\033[1;35m"
GREEN="\033[1;32m"; WHITE="\033[1;37m"; LIGHT_GRAY="\033[0;37m"; YELLOW="\033[1;33m"; CYAN="\033[1;36m"
NOCOLOR="\033[0m"

die() {
    echo "${LIGHT_RED}ERROR: $@. Exiting.${NOCOLOR}"
    exit 1
}

green()  echo "${GREEN}$@${NOCOLOR}"
out()    echo "${YELLOW}$@${NOCOLOR}"
blue()   echo "${BLUE}$@${NOCOLOR}"
yellow() echo "${YELLOW}$@${NOCOLOR}"
purple() echo "${PURPLE}$@${NOCOLOR}"
cyan()   echo "${CYAN}$@${NOCOLOR}"
red()    echo "${LIGHT_RED}$@${NOCOLOR}"

cyan "*** SETTING UP AND DEPLOYING EMSERVICES AND LYRISHQ-WEB ***"

[ -d lyris-hq ] || die There is no lyris-hq directory

if [ -z $(grep -Poe "FROM maven\:3\-jdk\-8 as builder" lyris-hq/authorization/Dockerfile) ]; then
out Patching Dockerfiles
cat<<EOF|git apply || die Git failed
diff --git a/emservices/app/Dockerfile b/emservices/app/Dockerfile
index 16de15d..a0b4d10 100644
--- a/emservices/app/Dockerfile
+++ b/emservices/app/Dockerfile
@@ -4,6 +4,9 @@ MAINTAINER Anas Taha <anas.taha@aurea.com>
 ENV GRAILS_VERSION 1.3.7
 
 RUN set -x && \\
+    sed -i 's/deb.debian.org/archive.debian.org/' /etc/apt/sources.list && \\
+    sed -i '/security.debian.org/d' /etc/apt/sources.list && \\
+    sed -i '/wheezy-updates/d' /etc/apt/sources.list && \\
     apt-get update && \\
     apt-get install -y --no-install-recommends unzip vim && \\
     rm -rf /var/lib/apt/lists/* && \\
@@ -48,7 +51,7 @@ ENV PATH \$CATALINA_HOME/bin:\$PATH
 ENV TOMCAT_STORAGE_URL https://archive.apache.org/dist/tomcat/tomcat-\$TOMCAT_MAJOR/v\$TOMCAT_VERSION/bin/apache-tomcat-\$TOMCAT_VERSION.tar.gz
 
 RUN cd /tmp && \\
-    wget "\$TOMCAT_STORAGE_URL" && \\
+    curl -sS -o apache-tomcat-\$TOMCAT_VERSION.tar.gz "\$TOMCAT_STORAGE_URL" && \\
     tar -xzvf apache-tomcat-\$TOMCAT_VERSION.tar.gz -C /usr/local && \\
     mv /usr/local/apache-tomcat-\$TOMCAT_VERSION \$CATALINA_HOME && \\
     rm -rf \$TOMCAT_TAR
diff --git a/lyris-hq/authorization/Dockerfile b/lyris-hq/authorization/Dockerfile
index 5c76700..32c9b9e 100644
--- a/lyris-hq/authorization/Dockerfile
+++ b/lyris-hq/authorization/Dockerfile
@@ -1,4 +1,4 @@
-FROM maven:3-jdk-7 as builder
+FROM maven:3-jdk-8 as builder
 MAINTAINER Anas Taha <anas.taha@aurea.com>
 
 COPY ./src ./files/build/ /home/app/
EOF
fi

out Make sure nexus container is started...
docker-compose up -d nexus || die Docker failed 

out Building emservices
docker build --network container:nexus -t emservices:latest ./emservices/app/ || die Docker failed 

out Building flex-build
docker build --network container:nexus -t flex-build:latest ./base/flex-build || die Docker failed 

out Building Lyris-HQ library
docker build --network container:nexus --rm ./lyris-hq/library || die Docker failed 

out Building Lyris-HQ hq-themes
docker build --network container:nexus --rm ./lyris-hq/hq-themes || die Docker failed 

out Building Lyris-HQ hq-uih-themes
docker build --network container:nexus --rm ./lyris-hq/hq-uih-themes || die Docker failed 

out Building Lyris-HQ authorization-flex
docker build --network container:nexus --rm ./lyris-hq/authorization-flex || die Docker failed 

out Building Lyris-HQ authorization
docker build --network container:nexus -t lhq-web:latest ./lyris-hq/authorization || die Docker failed 

out Starting lhq-web
docker-compose up -d lhq-web lhq-static || die Docker failed 

out Starting emservices
docker-compose up -d emservices ems-static || die Docker failed 

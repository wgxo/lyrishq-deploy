#!/bin/bash

# file: docker-bash
# author: @wgxo

# Utility to open shell terminals inside docker containers

# COLORS
BROWN="\033[0;33m"; BLUE="\033[1;34m"; RED="\033[0;31m"; LIGHT_RED="\033[1;31m"; PURPLE="\033[1;35m"
GREEN="\033[1;32m"; WHITE="\033[1;37m"; LIGHT_GRAY="\033[0;37m"; YELLOW="\033[1;33m"; CYAN="\033[1;36m"
NOCOLOR="\033[0m"

function green()  { echo -e "${GREEN}$@${NOCOLOR}"; }
function greenl() { echo -ne "${GREEN}$@${NOCOLOR}"; }
function out()    { echo -e "${BROWN}$@${NOCOLOR}"; }
function blue()   { echo -e "${BLUE}$@${NOCOLOR}"; }
function yellow() { echo -e "${YELLOW}$@${NOCOLOR}"; }
function purple() { echo -e "${PURPLE}$@${NOCOLOR}"; }
function cyan()   { echo -e "${CYAN}$@${NOCOLOR}"; }
function red()    { echo -e "${LIGHT_RED}$@${NOCOLOR}"; }

die() {
    red "ERROR: $@. Exiting."
    exit 1
}

purple "*** Open shell terminal inside docker container ***"

dockps='docker ps --format "table {{.Names}}\t{{.Ports}}"'
CONTAINERS=`eval $dockps|tail +2`
NUM=`echo -n "$CONTAINERS"|wc -l`

[ $NUM -ge 1 ] || die "There are no containers running!"

NUM=`echo $NUM+1|bc`

cyan "Select one:"
C=1
while read -r l; do 
    l=`echo $l|awk '{print $1}'|sed -e 's/_1$//' -e 's/_/\-/'`
    out " $C) $l"
    C=`echo $C+1|bc`
done <<< "$CONTAINERS" | column -t

greenl "Select [1-$NUM]: "
read OP

LINES=`echo $OP+1|bc`
CONT=`eval $dockps|tail +$LINES|head -1|awk '{print $1}'`
yellow Opening shell for $CONT...

(docker exec -ti $CONT bash -c "exit 0" >/dev/null 2>&1 && docker exec -ti $CONT bash) || \
  (docker exec -ti $CONT sh -c "exit 0" >/dev/null 2>&1 && docker exec -ti $CONT sh) || \
    red "Error starting a SHELL: bash and sh not found"

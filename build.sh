#!/bin/bash

# file: build.sh
# author: @wgxo

# This script builds a self-installer file

INSTALLER="lyrishq-installer.bsx"

echo "Build started."

cd `dirname $0`
cd payload
tar cf ../payload.tar ./*
cd ..

if [ -e "payload.tar" ]; then
    gzip -f payload.tar

    if [ -e "payload.tar.gz" ]; then
        cat decompress.sh payload.tar.gz > $INSTALLER
				rm -f payload.tar.gz
    else
        echo "payload.tar.gz does not exist"
        exit 1
    fi
else
    echo "payload.tar does not exist"
    exit 1
fi

chmod +x $INSTALLER

echo "Self-installer file created: $INSTALLER"

exit 0

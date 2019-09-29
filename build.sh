#!/bin/bash

INSTALLER="lyrishq-installer.bsx"

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
echo "$INSTALLER created"

exit 0

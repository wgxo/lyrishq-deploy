#!/bin/bash

# file: decompress.sh
# author: @wgxo

# This file decompresses the payload and calls the installer script.

echo ""
echo "Self Extracting Installer"
echo ""

export TMPDIR=`mktemp -d /tmp/selfextract.XXXXXX`

ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $0`

tail -n+$ARCHIVE $0 | tar xz -C $TMPDIR

CDIR=`pwd`
cd $TMPDIR

# Get installation directory
if [ $# -eq 0 ]; then CURDIR=$CDIR; else CURDIR=$1; fi
[ -d $CURDIR ] || (echo "Installation directory not found"; exit)

echo "Installation directory: $CURDIR"
echo ""

./installer.sh $CURDIR

cd $CDIR
rm -rf $TMPDIR

exit 0

__ARCHIVE_BELOW__

#!/bin/sh

# file: test-lhq-api.sh
# author: @wgxo

# Test script that calls the API endpoint in the emaillabs web interface

command -v http >/dev/null 2>&1 || (echo "HTTPie is not installed!"; exit)

http --timeout=300 emaillabs.ec2.internal/API/mailing_list.html type==list activity==query-listdata input=='<DATASET>
 <DATA type="extra" id="encoding">utf-8</DATA>
 <SITE_ID>1000002</SITE_ID>
 <MLID>2</MLID>
 <DATA type="EXTRA" ID="PAGINATION">yes</DATA>
 <DATA type="EXTRA" ID="PAGE">1</DATA>
 <DATA type="EXTRA" ID="LINES">50</DATA>
 <DATA type="EXTRA" ID="SEARCH"/>
 <DATA type="EXTRA" ID="SORTORDER">DESC</DATA>
 <DATA type="EXTRA" ID="SORTCOLUMN">date</DATA>
 <DATA TYPE="EXTRA" ID="PASSWORD">admin</DATA>
</DATASET>"
'


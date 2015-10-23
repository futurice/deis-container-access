#!/bin/sh -
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${MYDIR}/settings.sh

OUTPUT="$(bash ${MYDIR}/output.sh)"
echo "${OUTPUT}"|tee /tmp/index.txt

cat /tmp/index.txt|curl --interface eth0 --data-binary @- -X POST $DCA_APP/incoming -H "Content-Type:text/html"

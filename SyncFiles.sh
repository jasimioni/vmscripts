#!/bin/bash

REMOTEDIR=$(pwd | sed -e 's/.*cases\//\/customers\//')
REMOTE="sftp://files.support.canonical.com$REMOTEDIR"

echo "Downloading from $REMOTE"

lftp -c mirror --only-missing --parallel $REMOTE .

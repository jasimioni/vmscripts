#!/bin/bash

REMOTEDIR=$(pwd | sed -e 's/.*cases\//\/customers\//')

lftp -c mirror --parallel sftp://files.support.canonical.com$REMOTEDIR .

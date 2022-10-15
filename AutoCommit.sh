#!/bin/bash

cd $(dirname $0)

git pull
git commit -m "$(date)" -a
git push

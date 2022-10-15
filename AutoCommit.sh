#!/bin/bash

cd $(dirname $0)

git commit -m "$(date)" -a
git push

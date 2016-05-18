#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: ./publish.sh \"commit message\""
    exit 1;
fi

sculpin generate --env=prod

cp -R output_prod/* .
rm -rf output_*

git add *
git commit -m "$1"
git push origin --all
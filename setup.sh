#/bin/bash

set -e

cd ./pull/
docker-compose up -d

cd ../push/
docker-compose up -d

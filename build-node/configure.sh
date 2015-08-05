#!/bin/bash

$(boot2docker shellinit)

echo ""
echo "Stopping and removing existing containers..."
echo ""
CONTAINERS=( build )
for c in ${CONTAINERS[@]}; do
	docker stop ${c} > /dev/null 2>&1
	docker rm -f ${c} > /dev/null 2>&1
done

echo ""
echo "Create BUILD distribution folder..."
echo ""
grunt --gruntfile ../BUILD/BUILD/Gruntfile.js dist

echo ""
echo "Copying dist folder..."
echo ""
cp -rf ../BUILD/BUILD/dist build

echo ""
echo "Update BUILD configuration file with MongoDB node name..."
echo ""
python ../updateConfig.py 'build/server/config.json' 'build-DB-01'

echo ""
echo "Building BUILD from Dockerfile..."
echo ""
docker build -t longieirl/build:0.1.0 .

sleep 30

echo ""
echo "Removing files..."
echo ""
rm -rf BUILD

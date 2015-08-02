#!/bin/bash

# #####################################
# Disk Space
# boot2docker destroy
# boot2docker init
# docker stop $(docker ps -a -q)
# docker rm $(docker ps -a -q)
# docker rmi -f $(docker images | grep "<none>" | awk "{print \$3}")

# #####################################
# Docker versions 1.7
# Installer: http://docs.docker.com/mac/step_one/
# Client & Server needs to be the same:
# boot2docker stop
# boot2docker download
# boot2docker up
# Note: doing this will remove existing containers

# Virtual Box v5
# https://www.virtualbox.org/wiki/Downloads

# Issue with x509 certs
# boot2docker ssh 'sudo /etc/init.d/docker restart'
# --tlsverify=false should never be a recommended workaround

$(boot2docker shellinit)

echo ""
echo "Stopping and removing existing containers.."
echo ""
containers=( build_DB_01 build_DB_02 build_arbiter build-data-mongo build-node)
for c in ${containers[@]}; do
	docker stop ${c} > /dev/null 2>&1
	docker rm -f ${c} > /dev/null 2>&1
done

echo ""
echo "Building VM's from Dockerfiles..."
echo "- comment out these lines if you want to use existing image tags"
echo ""
# Build docker data volumes - Single Responsibility Principle (SRP)
docker build -t longieirl/base base/
docker build -t longieirl/mongo mongo/
docker build -t longieirl/mongo-data mongo-data/
docker build -t longieirl/node node/

echo ""
echo "Build data container for mongo i.e. logs/journal/data"
echo ""
docker run -itd --name build-data-mongo longieirl/mongo-data

echo ""
echo "Build replica set with 3 mongodb nodes..."
echo ""
# With three members, majority required to vote is 2, fault tolerance is 1. 
# Note: later we add arbiter which only casts votes
# Refer: http://docs.mongodb.org/manual/core/replica-set-architecture-four-members/
# TODO use docker compose here using the 'scale' attribute to start up x amount of mongodb instances
docker run -itd -p 27017:27017 --name build_DB_01 --volumes-from build-data-mongo --detach --publish-all longieirl/mongo mongod --config /conf/mongo.conf --dbpath /data/mongo-01 --logpath /log/mongoReplica-01.log
docker run -itd --name build_DB_02 --volumes-from build-data-mongo --detach --publish-all longieirl/mongo mongod --config /conf/mongo.conf --dbpath /data/mongo-02 --logpath /log/mongoReplica-02.log

# Adding arbiter as the majority of the members must be accissible for an election to take place
docker run -itd --name build_arbiter -p 30000:30000 --volumes-from build-data-mongo --detach --publish-all longieirl/mongo mongod --dbpath /data/arb --config /conf/mongo-arb.conf --logpath /log/arbiter.log

MONGODB1=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' build_DB_01)
MONGODB2=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' build_DB_02)
ARBITER=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' build_arbiter)

echo ""
echo "Getting IP addresses of Mongo instances..."
echo ""
echo $MONGODB1
echo $MONGODB2
echo $ARBITER

echo ""
echo "Configure ReplicaSet on primary..."
echo ""
read -r -d '' MONGOCONFIG <<- EOM
	printjson(rs.initiate({ _id : 'localDev', members : [ {_id : 0, host : '$MONGODB1:27017'}, {_id : 1, host : '$MONGODB2:27017'} ] }));
EOM
docker exec build_DB_01 mongo $MONGODB1:27017 --quiet --eval "$MONGOCONFIG"

echo ""
echo "Waiting for everything to come online...."
echo ""
sleep 20

echo ""
echo "Adding arbiter to primary...(2 mongodb, 1 arbiter)"
echo ""
docker exec build_DB_01 mongo $MONGODB1:27017 --quiet --eval "printjson(rs.addArb('$ARBITER:30000'))"

read -r -d '' ECHOCONFIG <<- EOM
	printjson( rs.status() );
EOM

echo ""
echo "Current mongod configuration..."
echo ""
docker exec -it build_DB_01 mongo --quiet --eval "$ECHOCONFIG"

echo ""
echo "Replace localhost with mongodb instance IP address..."
echo ""
python updateConfig.py $MONGODB1

echo ""
echo "Run and execute BUILD application..."
echo ""
# Adding -e here to make python available as env variable
docker run --rm -e PYTHON=/usr/bin/python -e GYP_MSVS_VERSION=2012 -v $PWD/BUILD/BUILD:/app longieirl/node npm install
docker run --rm --link build_DB_01:build_DB_01 -v $PWD/BUILD/BUILD:/app longieirl/node node server/initSchema.js
docker run --rm --link build_DB_01:build_DB_01 -v $PWD/BUILD/BUILD:/app longieirl/node node server/setDefaultAccess.js
docker run -itd -p 9000:9000 --name build-node -v $PWD/BUILD/BUILD:/app longieirl/node grunt serve
sleep 200

echo ""
echo "Enabling default ports..."
echo ""
VBoxManage controlvm boot2docker-vm natpf1 mongodb,tcp,,27017,,27017
VBoxManage controlvm boot2docker-vm natpf1 build,tcp,,9000,,9000

echo ""
echo "#####################################"
echo "Monitor BUILD coming online"
echo "$ docker logs build-node"
echo ""

echo ""
echo "#####################################"
echo "Connect to primary replica mongodb instance via OS X:"
echo "$ mongo $(boot2docker ip)":27017
echo ""

echo "#####################################"
echo "Access database logs for all mongodb nodes:"
echo "$ docker exec -it build-data-mongo bash"
echo "$ tail -f /log/mongodb/mongoReplica-01.log"
echo "$ tail -f /log/mongodb/mongoReplica-02.log"
echo "$ tail -f /log/mongodb/arbiter.log"
echo ""
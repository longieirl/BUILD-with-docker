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

if [ ! -z `which boot2docker` ]
	then
		# Init docker environment on Mac and Windows
		$(boot2docker shellinit)
	else
		if [ -z `which docker` ]
			then
				echo "Neither docker nor boot2docker found"
				echo "Please check your PATH"
				exit 127
		fi
fi

echo ""
echo "Setting default params..."
echo ""
MONOGO_VERSION=2.6.0
MONOGO_PORT=27017
BUILD_VERSION=0.1.0
BUILD_PORT=9000

echo ""
echo "Stopping and removing existing containers..."
echo ""
containers=( build-DB-01 build-DB-02 build-arbiter build-data-mongo build-node)
for c in ${containers[@]}; do
	docker stop ${c} > /dev/null 2>&1
	docker rm -f ${c} > /dev/null 2>&1
done

echo ""
echo "Building VM's from Dockerfiles..."
echo "- comment out these lines if you want to use different image tags"
echo ""
# Build docker data volumes - Single Responsibility Principle (SRP)
docker build -t longieirl/base base/
docker build -t longieirl/mongo mongo/
docker build -t longieirl/mongo-data mongo-data/
docker build -t longieirl/node node/

echo ""
echo "Build data container for mongo i.e. logs/journal/data..."
echo "- this data store holds all the logs and data for ALL the MongoDB instances"
echo ""
docker run -itd --name build-data-mongo longieirl/mongo-data

echo ""
echo "Build replica set with 3 mongodb nodes..."
echo ""
# With three members, majority required to vote is 2, fault tolerance is 1. 
# Note: later we add arbiter which only casts votes
# Refer: http://docs.mongodb.org/manual/core/replica-set-architecture-four-members/
docker run -itd -p $MONOGO_PORT:$MONOGO_PORT --name build-DB-01 --volumes-from build-data-mongo --detach --publish-all longieirl/mongo:$MONOGO_VERSION mongod --config /conf/mongo.conf --dbpath /data/mongo-01 --logpath /log/mongoReplica-01.log
docker run -itd --name build-DB-02 --volumes-from build-data-mongo --detach --publish-all longieirl/mongo:$MONOGO_VERSION mongod --config /conf/mongo.conf --dbpath /data/mongo-02 --logpath /log/mongoReplica-02.log

# Adding arbiter as the majority of the members must be accissible for an election to take place
docker run -itd --name build-arbiter -p 30000:30000 --volumes-from build-data-mongo --detach --publish-all longieirl/mongo:$MONOGO_VERSION mongod --dbpath /data/arb --config /conf/mongo-arb.conf --logpath /log/arbiter.log

echo ""
echo "Getting IP addresses of Mongo instances..."
echo ""
MONGODB1=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' build-DB-01)
MONGODB2=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' build-DB-02)
ARBITER=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' build-arbiter)
echo $MONGODB1 + ' (build-DB-01)'
echo $MONGODB2 + ' (build-DB-02)'
echo $ARBITER + ' (build-arbiter)'

echo ""
echo "Configure replica set on primary MongoDB instance..."
echo ""
read -r -d '' MONGOCONFIG <<- EOM
	printjson(rs.initiate({ _id : 'localDev', members : [ {_id : 0, host : '$MONGODB1:27017'}, {_id : 1, host : '$MONGODB2:27017'} ] }));
EOM
docker exec build-DB-01 mongo $MONGODB1:27017 --quiet --eval "$MONGOCONFIG"

echo ""
echo "Waiting for everything to come online...."
echo ""
sleep 20

echo ""
echo "Adding arbiter to primary..."
echo ""
docker exec build-DB-01 mongo $MONGODB1:27017 --quiet --eval "printjson(rs.addArb('$ARBITER:30000'))"

read -r -d '' ECHOCONFIG <<- EOM
	printjson( rs.status() );
EOM

echo ""
echo "Update BUILD configuration file with MongoDB primary node..."
echo ""
python updateConfig.py 'BUILD/BUILD/server/config.json' $MONGODB1

echo ""
echo "Run and execute BUILD application..."
echo ""
# Adding -e here to make python available as env variable
docker run --rm -v $PWD/BUILD/BUILD:/app -e PYTHON=/usr/bin/python -e GYP_MSVS_VERSION=2012 longieirl/node npm install
docker run --rm -v $PWD/BUILD/BUILD:/app longieirl/node node server/initSchema.js
docker run --rm -v $PWD/BUILD/BUILD:/app longieirl/node node server/setDefaultAccess.js
docker run -itd -v $PWD/BUILD/BUILD:/app -p $BUILD_PORT:$BUILD_PORT --link build-DB-01:build-DB-01 --name build-node longieirl/node grunt serve
# This step can take up to 2mins, it builds the CSS, sprites etc...
sleep 200

echo ""
echo "Enabling BUILD and MongoDB ports..."
echo ""
VBoxManage controlvm boot2docker-vm natpf1 mongodb-script,tcp,,27017,,27017
VBoxManage controlvm boot2docker-vm natpf1 build-script,tcp,,$BUILD_PORT,,$BUILD_PORT

echo ""
echo "#####################################"
echo "Monitor BUILD"
echo "$ docker logs build-node"
echo ""

echo ""
echo "#####################################"
echo "Connect to MongoDB replica set:"
echo "$ mongo $(boot2docker ip)":$MONGO_PORT
echo ""

echo "#####################################"
echo "Access database logs for all mongodb nodes:"
echo "$ docker exec -it build-data-mongo bash"
echo "$ tail -f /log/mongodb/mongoReplica-01.log"
echo "$ tail -f /log/mongodb/mongoReplica-02.log"
echo "$ tail -f /log/mongodb/arbiter.log"
echo ""

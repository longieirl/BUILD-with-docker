#!/bin/bash

$(boot2docker shellinit)

echo ""
echo "Stopping and removing existing containers..."
echo ""
CONTAINERS=( build-DB-01 build-DB-02 build-arbiter build-data-mongo build)
for c in ${CONTAINERS[@]}; do
	docker stop ${c} > /dev/null 2>&1
	docker rm -f ${c} > /dev/null 2>&1
done

echo ""
echo "Build data container for mongo i.e. logs/journal/data..."
echo "- this data store holds all the logs and data for ALL the MongoDB instances"
echo ""
docker run -itd --name build-data-mongo longieirl/mongo-data:latest

echo ""
echo "Build replica set with 3 mongodb nodes..."
echo ""
# With three members, majority required to vote is 2, fault tolerance is 1.
# Note: later we add arbiter which only casts votes
# Refer: http://docs.mongodb.org/manual/core/replica-set-architecture-four-members/
docker run -itd -p 27017:27017 --name build-DB-01 --volumes-from build-data-mongo --detach --publish-all longieirl/mongo:2.6.0 mongod --config /conf/mongo.conf --dbpath /data/mongo-01 --logpath /log/mongoReplica-01.log
docker run -itd --name build-DB-02 --volumes-from build-data-mongo --detach --publish-all longieirl/mongo:2.6.0 mongod --config /conf/mongo.conf --dbpath /data/mongo-02 --logpath /log/mongoReplica-02.log

# Adding arbiter as the majority of the members must be accissible for an election to take place
docker run -itd --name build-arbiter -p 30000:30000 --volumes-from build-data-mongo --detach --publish-all longieirl/mongo:2.6.0 mongod --dbpath /data/arb --config /conf/mongo-arb.conf --logpath /log/arbiter.log

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
echo "Enabling BUILD [9000] and MongoDB [27017] ports..."
echo ""
VBoxManage controlvm boot2docker-vm natpf1 mongodb-script,tcp,,27017,,27017
VBoxManage controlvm boot2docker-vm natpf1 build-script,tcp,,9000,,9000

echo ""
echo "Run BUILD application..."
echo ""
docker run --link build-DB-01:build-DB-01 --rm longieirl/build:latest node /build/server/initSchema.js
docker run --link build-DB-01:build-DB-01 --rm longieirl/build:latest node /build/server/setDefaultAccess.js
docker run --link build-DB-01:build-DB-01 -itd --name build -p 9000:9000 longieirl/build:0.1.0

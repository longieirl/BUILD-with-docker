#
# Data volume Dockerfile
#
# Base
FROM longieirl/build-base

MAINTAINER Build Team

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mongodb && useradd -r -g mongodb mongodb

RUN mkdir -p /journal /data /log /data/mongo-01 /data/mongo-02 /data/mongo-03 /data/arb
RUN chown -R mongodb:mongodb /journal \
    && chown -R mongodb:mongodb /data \
    && chown -R mongodb:mongodb /log

# Define mountable directory
VOLUME /log
VOLUME /data

# Define default command
# CMD ["--quiet"]

CMD /bin/sh
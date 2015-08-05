#!/bin/bash

# #####################################
# Install and run BUILD
# #####################################
git clone https://github.com/longieirl/build-with-docker.git build-with-docker
cd build-with-docker
chmod 755 /build-node/run.sh
./build-node/run.sh

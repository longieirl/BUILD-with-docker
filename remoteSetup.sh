#!/bin/bash

# #####################################
# Install and run BUILD
# #####################################
git clone https://github.com/longieirl/build-with-docker.git build-with-docker
cd build-with-docker
git clone https://github.com/SAP/BUILD.git BUILD
chmod 755 start.sh
./start.sh

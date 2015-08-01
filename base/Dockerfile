#
# Base image Dockerfile
#

# Base
FROM ubuntu:14.04

MAINTAINER Build Team

RUN apt-get update
RUN apt-get update --fix-missing
RUN apt-get update --fix-missing

# Update packages
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
	apt-get update -qqy && \  
	apt-get -qqy install ca-certificates openssl make gcc curl wget vim git git-core && \
	apt-get clean autoclean && \  
	apt-get autoremove && \  
  	apt-get update && \  
    rm -rf /var/lib/apt/lists/*

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get autoremove -y

# Set environment variables
ENV HOME /root
ENV LANG C.UTF-8
ENV LC_ALL en_US.UTF-8
ENV NODE_VERSION 0.10.38
ENV NPM_VERSION 1.4.28
RUN locale-gen en_US.UTF-8

# Install Node
RUN cd /opt && \
    wget http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz && \
    tar -xzf node-v$NODE_VERSION-linux-x64.tar.gz && \
    mv node-v$NODE_VERSION-linux-x64 node && \
    cd /usr/local/bin && \
    ln -s /opt/node/bin/* . && \
    rm -f /opt/node-v$NODE_VERSION-linux-x64.tar.gz && \
    PATH=/usr/bin/node:$PATH

# Configure node
RUN node -v && \
    npm -v && \
    npm install -g grunt-cli  && \
    npm install -g nodemon && \
    npm cache clear

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["bash"]


### Install and Run SAP BUILD 

https://github.com/SAP/BUILD

### Prerequisites
- Tested on OS X
- boot2docker 1.7 is installed
- git is installed from the cli
- The following ports are not bound on your host
```
9000 - BUILD App
27017 - MongoDB
```
- setup.sh script will automatically add the ports to your boot2docker vm ```boot2docker-vm```

### Remote Install
Download and install in one go!

```
$ curl https://raw.githubusercontent.com/longieirl/build-with-docker/master/remoteSetup.sh | bash
```
Note: this entire process can take up to 20mins depending on network connection and CPU power....be patient!

### Local Install

- Clone the setup repo
```
$ git clone https://github.com/longieirl/build-with-docker.git build-with-docker
```

- Change into setup directory and clone BUILD
```
$ cd build-with-docker
$ git clone https://github.com/SAP/BUILD.git BUILD
```

- Run setup to install MongoDB Replica set and BUILD
```
$ ./setup.sh
```
Note: you may need to run this one or twice if you experience any of the errors below. Until BUILD is bumped to the latest version of NodeJS and NPM this is a problem.

- Login
Open URL using Chrome, the recommended browser for SAP BUILD
```
http://localhost:9000/login
```
Note: if the server does not come up, watch the logs to see what is happening:
```sh
$ docker logs build-node
```

### Errors
- If you get the following error, just run ./setup.sh again. This is an issue with the version of NPM - all the modules that were previously downloaded will still be availble.
```
path /root/.npm/a58c529b-oot-npm-lodash-2-4-2-package-tgz.lock
```
Note: it can be any package that is locked, this is just one example.

- If you get a node-gyp rebuild error, the install will still work as it will use the JS version instead so this is NOT a blocker! Looking to resolve this issue!
```sh
gyp ERR! configure error 
gyp ERR! stack Error: spawn ENOENT
gyp ERR! stack     at errnoException (child_process.js:1011:11)
gyp ERR! stack     at Process.ChildProcess._handle.onexit (child_process.js:802:34)
gyp ERR! System Linux 4.0.5-boot2docker
gyp ERR! command "node" "/opt/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js" "rebuild"
gyp ERR! cwd /app/node_modules/norman-auth-server/node_modules/x.509
gyp ERR! node -v v0.10.38
gyp ERR! node-gyp -v v1.0.1
gyp ERR! not ok 
npm WARN optional dep failed, continuing x.509@0.1.4
```

### TODO
- [ ] Automate entire setup using vagrant/fig
- [ ] Use docker-compose for creating containers i.e. using the scale option for the replica creation
- [ ] Stop/start scripts to persist data between container restarts, all data is lost each time setup.sh is run
- [ ] Make the various dockerfiles, scripts etc...more configurable i.e. taking NPM version as a parameter 
- [ ] Hosting this on AWS and other cloud solutions
### Install and Run SAP BUILD 
BUILD is an open-source, cloud-based and social platform that enables users, even those with no UI development knowledge, to easily create fully interactive prototypes with realistic data, share them with colleagues and consolidate this feedback without writing a line of code.
Link: https://github.com/SAP/BUILD

### Prerequisites
- Ensure boot2docker is installed
- Ensure git is installed from the cli
- Enable port forwarding on VirtualBox for the following ports:
```
9000 - BUILD App
27017 - MongoDB
```

### Remote Install
Download and install in one go!

```
$ curl https://raw.githubusercontent.com/longieirl/build-with-docker/master/remoteSetup.sh | bash
```
Note: this entire process can take up to 20mins depending on network connection

### Local Install

- Clone this repo
```
$ git clone https://github.com/longieirl/build-with-docker.git build-with-docker
```

- Change into BUILD directory and clone BUILD
```
$ cd build-with-docker
$ git clone https://github.com/SAP/BUILD.git BUILD
```

- Run setup to install MongoDB Replica set and BUILD
```
$ ./setup.sh
```

- Login
Open URL using chrome, the recommended browser for SAP BUILD
```
http://localhost:9000/login
```
Note: if the server does not come up, watch the logs to see what is happening
```sh
$ docker logs build-node
```

### Errors
If you get the following error, just run ./setup.sh again. This is an issue with the version of NPM - all the modules that were previously downloaded will still be availble.
```
path /root/.npm/a58c529b-oot-npm-lodash-2-4-2-package-tgz.lock
```
Note: if you have npm installed on your command line then you can manually run this step yourself and then ./setup.sh again
```sh
cd BUILD/BUILD/
npm install
```

If you get a node-gyp rebuild error, the install will still work! Looking to resolve this issue!
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
- Use docker-compose for creating containers i.e. using the scale option for the replica creation
- Stop/start scripts to presist data between container restarts
- Make node/npm versions configurable from docker run commands

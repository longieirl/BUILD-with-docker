### Install and Run SAP BUILD 

https://github.com/SAP/BUILD

Ensure boot2docker is installed
Ensure git is installed

Enable port forwarding on VirtualBox for the following ports: 
```
9000 - BUILD App
27017 - MongoDB
```

### Remote Install
Download and install in one go!

```
$ curl -o remoteSetup.sh https://raw.githubusercontent.com/longieirl/build-with-docker/master/remoteSetup.sh
$ chmod 755 remoteSetup.sh
$ ./remoteSetup.sh
```
Note: this entire process can take up to 20mins depending on network connection

### Local Install

- Clone this repo
```
git clone https://github.com/longieirl/build-with-docker.git build-with-docker
```

- cd into build-with-docker and clone BUILD
```
git clone https://github.com/SAP/BUILD.git BUILD
```

- Run setup to install MongoDB Replica set and BUILD
```
$ ./start.sh
```

- Login
```
http://localhost:9000/login
```
Note: if the server does not come up watch the logs 
```sh
$ docker logs build-node
```

### Errors
If you get the following error, just run ./start.sh again. This is an issue with the version of NPM - all the modules that were previously downloaded will still be availble.
```
path /root/.npm/a58c529b-oot-npm-lodash-2-4-2-package-tgz.lock
```
Note: if you have npm installed on your command line then you can manually run this step yourself and then ./start.sh again
```sh
cd BUILD/BUILD/
npm install
```

If you get a node-gyp rebuild error, the install will work! Still looking to resolve this issue
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

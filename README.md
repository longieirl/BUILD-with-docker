### Install and Run SAP BUILD 

https://github.com/SAP/BUILD

Ensure boot2docker is installed

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

### Local Install

1. Clone this repo
```
git clone https://github.com/longieirl/build-with-docker.git build-with-docker
```

2. In the root directory, clone BUILD
```
git clone https://github.com/SAP/BUILD.git BUILD
```

3. Run setup to install MongoDB Replica set and BUILD
```
$ ./start.sh
```

4. Login
```
http://localhost:9000/login
```
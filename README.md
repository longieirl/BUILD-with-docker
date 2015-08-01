### Install and Run SAP BUILD 

https://github.com/SAP/BUILD

Ensure boot2docker is installed

2. Enable port forwarding on VirtualBox 
```
[9000 & 27017] 
```

### Remote Install

$ curl -o remoteScript http://www.gnu.org/software/gettext/manual/gettext.html

### Local Install

1. In the root directory, clone BUILD
```
git clone https://github.com/SAP/BUILD.git BUILD
```

2. Run setup to install MongoDB Replica set and BUILD
```
$ ./start.sh
```

Note: this can take up to 20 minutes
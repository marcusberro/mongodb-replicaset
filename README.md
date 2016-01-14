# mongodb-replicaset
Sample scripts to start MongoDB Replica Sets

## What you are going to find here?
There is a set of scripts inside project folders. They help you to bring replica set up and down. Each folder has a specific content detailed below

### 01 - Replica Set configuration
Start a 3-node replica set and activate replication

#### Enter in sample folder
```bash
cd $PATH_TO_PROJECT/01-simple-replset
```

#### First time starting cluster and replication
```bash
./start-cluster.sh
./start-replication.sh
```

#### Stop and restart cluster (Mongo starts replication automatically if replication is already started)
```bash
./stop-cluster.sh
./restart-cluster.sh
```

#### Purge cluster (After purging you need to start cluster and replication again)
```bash
./purge-cluster.sh
```

#### Purge and start cluster at same script (you need to start replication again)
```bash
./purge-start-cluster.sh
./start-replication.sh
```

#### Change each node configuration as you wish: ports, storage, oplogSize, security, logs, profiling... 
```yaml
net:
   port: 27017

storage:
   dbPath: db
   directoryPerDB: true
   journal:
      enabled: true
   mmapv1:
      smallFiles: true

replication:
   oplogSizeMB: 50
   replSetName: rs

systemLog:
   destination: file
   path: db/mongodb.log
   logAppend: true
   timeStampFormat: iso8601-utc

operationProfiling:
   slowOpThresholdMs: 100
```

### 02 - Replica Set with one arbiter
Start a 2-node and one-arbiter replica set and activate replication

#### replication-cluster.json is quite different from the other
```json
{
   _id: "rs",
   members: [
      {
         _id: 0,
         host: "localhost:27020",
         priority: 2
      },
      {
         _id: 1,
         host: "localhost:27021",
         priority: 1
      },
      {
         _id: 2,
         host: "localhost:27022",
         arbiterOnly: true
      }
   ]
}

```
There is a "arbiterOnly: true" in 3rd node. Arbiters don't contains data, but they can participate in an election

### 03 - Replica Set with security enabled
Start a 3-node replica set with security enabled and activate replication

#### mongodb.conf files has a security session in each node
```bash
...
security:
   authorization: enabled
   keyFile: mongodb-keyfile
...
```

#### This script creates a default user called dbAdmin with root role. The authentication process can be done like these
```javascript
MongoDB shell console
...
> use admin
> db.auth("dbAdmin","dbAdmin")
...
```
or
```javascript
mongo --port 27023 -u dbAdmin -p dbAdmin --authenticationDatabase=admin
```

Once logged, you can create other users or change script to create users before start cluster - TODO: build a json file that contains users
```javascript
...
if(replStatus && replStatus.ok === 1){
	
	db = db.getSiblingDB("admin");

	if(!db.auth("dbAdmin","dbAdmin")){
		print(" ### Creating DB Admin user...");

		var adminUser = db.createUser({ user: "dbAdmin", pwd: "dbAdmin", roles: [ { role: "userAdminAnyDatabase", db: "admin" }, {role:"root", db: "admin"} ] });

		var dbAdimOk = db.auth("admin","latam");

		print("DB Admin authentication after create: "+dbAdimOk);
	} else {
		print(" ### Logged with DB Admin user");
	}
} else {
...
```
You may know that there is a mongodb-keyfile inside each node folder. Mongo instances communicate each other using that key.


### TODO - 04 - Replica Set with tags
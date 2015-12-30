# mongodb-replicaset
Sample scripts to start MongoDB Replica Sets

## What you are going to find here?
There is a set of scripts inside project folders. They help you to bring replica set up and down. Each folder has a specific content detailed below

> Warning: make sure you are inside each folder before run any script
> TODO: Improve here

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

### TODO - 02 - Replica Set with one arbiter
Start a 2-node and one-arbiter replica set and activate replication

### TODO - 03 - Replica Set with security enabled
Start a 3-node replica set with security enabled and activate replication

### TODO - 04 - Replica Set with tags
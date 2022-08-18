## Mongodb cluster On Kubernetes ##

### After deploying mongo cluster first time, use below commands to setup the cluster:
```bash
kubectl apply -f svc.yaml

kubectl apply -f pv.yaml 

kubectl apply -f mongo_satateful.yaml 

kubectl exec -it mongo-0 mongo

rs.initiate()

var cfg = rs.conf()

cfg.members[0].host="mongo-0.mongo:27017"

rs.reconfig(cfg)

rs.status()

rs.add("mongo-1.mongo:27017")

rs.add("mongo-2.mongo:27017")

rs.add("mongo-3.mongo:27017")

rs.status()
```

### Mongo Restore backup script ###

```bash
export datee=`date +"%d-%m-20%y-%H%M%S"`
mkdir /usr/local/Mongo_backup/$datee
echo " $datee directory created inside /usr/local/Mongo_backup folder --> $?"
kubectl -it exec mongo-0 -- bash -c "rm -rf /tmp/mongo_backup.gz"
kubectl -it exec mongo-0 -- bash -c "mongodump --archive=/tmp/mongo_backup.gz --gzip"
echo "MongoDump status--> $?"
kubectl cp mongo-0:/tmp/mongo_backup.gz /usr/local/Mongo_backup/$datee/mongo_backup.gz
echo "MongoDump data copied to /usr/local/Mongo_backup/$datee directory --> $?"
```

### Mongo Restore backup script ###

```bash
echo "Plz enter folder name of mongodump :- "
read folder
echo""
kubectl cp /usr/local/Mongo_backup/$folder/mongo_backup.gz mongo-0:/tmp/mongo_backup.gz 
echo "Tar file copied inside pod--> $?"
kubectl -it exec mongo-0 -- bash -c "mongorestore  --archive=/tmp/mongo_backup.gz --gzip --drop"
echo "MongoRestore staus--> $?"
```


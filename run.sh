#!/bin/bash

docker run -d --name opscenter -p 8888:8888 bochen/opscenter:5.2.1
sleep 10

CLUSTER_NAME=Bochen

docker run -d --name cassandra -p 9042:9042 -p 9160:9160 -p 7199:7199 -e CASSANDRA_CLUSTER_NAME=${CLUSTER_NAME} --link opscenter bochen/cassandra:2.2.2
sleep 20

docker run -d --name cassandra2 -e CASSANDRA_CLUSTER_NAME=${CLUSTER_NAME} --link opscenter --link cassandra bochen/cassandra:2.2.2
sleep 20

curl \
-X POST \
-d \
"{
	\"cassandra\": {
		\"seed_hosts\": \"$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' cassandra)\"
	},
	\"cassandra_metrics\": {},
	\"jmx\": {
		\"port\": \"7199\"
	}
}" http://$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' opscenter):8888/cluster-configs

docker run -d --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 bochen/zookeeper:3.4.6
sleep 10

docker run -d --name kafka -p 9092:9092 -p 9898:9898 -e KAFKA_LOG_RETENTION_HOURS=1 --link zookeeper:zk bochen/kafka:0.8.2.2
sleep 10

docker run -d --name storm-nimbus -p 3772:3772 -p 3773:3773 -p 6627:6627 --link zookeeper:zk bochen/storm-nimbus:0.9.5
sleep 15

docker run -d --name storm-ui -p 9999:8080 --link storm-nimbus:nimbus --link zookeeper:zk bochen/storm-ui:0.9.5
sleep 5

docker run -d --name storm-supervisor -p 9100:8000 --link storm-nimbus:nimbus --link zookeeper:zk --link kafka --link cassandra bochen/storm-supervisor:0.9.5
sleep 15

docker run -d --name storm-supervisor2 -p 9200:8000 --link storm-nimbus:nimbus --link zookeeper:zk --link kafka --link cassandra bochen/storm-supervisor:0.9.5
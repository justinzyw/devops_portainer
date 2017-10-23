#!/bin/bash

# Fetch the variables
. parm.txt

# function to get the current time formatted
currentTime()
{
  date +"%Y-%m-%d %H:%M:%S";
}

sudo docker service scale devops-portainer=0

echo ---$(currentTime)---populate the volumes---
#to zip, use: sudo tar zcvf devops_portainer_volume.tar.gz /var/nfs/volumes/devops_portainer*
sudo tar zxvf devops_portainer_volume.tar.gz -C /

echo ---$(currentTime)---create portainer service---
sudo docker service create -d \
--publish $PORTAINER_PORT:9000 \
--name devops-portainer \
--mount type=volume,source=devops_portainer_volume,destination=/data,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_portainer_volume \
--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
--network $NETWORK_NAME \
--replicas 1 \
--constraint 'node.role == manager' \
$PORTAINER_IMAGE \
-H unix:///var/run/docker.sock

sudo docker service scale devops-portainer=1
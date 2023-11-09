#!/bin/bash

IMAGE_NAME="alpine-custom"
IMAGE_ARCHIVE=$IMAGE_NAME.tar.gz
NETWORK_NAME="custom-bridge"
SERVER_NAME="alp-server"
CLIENT_NAME="alp-client"

SENT_FILE=file-to-send
RECEIVED_FILE=file-received


echo -e "\n==== Create custom bridge network (if not exists) ..."
sudo docker network create custom-bridge 2>/dev/null

if [ -f $IMAGE_ARCHIVE ];
then
	echo -e "\n\n==== Image archive found - loading from $IMAGE_ARCHIVE"
	sudo docker load < $IMAGE_ARCHIVE
else
	echo -e "\n==== Build image from Dockerfile ..."
	sudo docker image build -f Dockerfile -t $IMAGE_NAME .

	echo -e "\n==== Save docker image to $IMAGE_NAME.tar.gz"
	sudo docker image save $IMAGE_NAME | gzip > $IMAGE_NAME.tar.gz
fi


echo -e "\n\n==== Run server and client containers ..."
sudo docker container run -it -d --network $NETWORK_NAME --name $SERVER_NAME --publish 80:80 -v $(pwd):/home $IMAGE_NAME
sudo docker container run -it -d --network $NETWORK_NAME --name $CLIENT_NAME --publish 81:81 -v $(pwd):/home $IMAGE_NAME

echo -e "\n==== Start server script in server container ..."
sudo docker exec -d $SERVER_NAME sh -c "/home/netcat-server.sh"
sleep 1

echo -e "\n==== Retrieve IP address of server container"
SERVER_IP=`sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $SERVER_NAME`

echo "SERVER_IP: " $SERVER_IP

echo -e "\n==== Start client script in client container ...\n\n"
sudo docker exec -d $CLIENT_NAME sh -c "/home/netcat-client.sh $SERVER_IP"
sleep 1

echo "========================================================"
echo "====         Compare sent and received files ... ======="
echo "========================================================"
ls -l $SENT_FILE $RECEIVED_FILE

if diff $SENT_FILE $RECEIVED_FILE ; then
   echo -e "\n[PASSED]: $SENT_FILE and $RECEIVED_FILE are identical"
else
   echo -e "\n[ERROR]: $SENT_FILE and $RECEIVED_FILE are different but expected to be identical"
fi
echo "================================================"



echo -e "\n\n==== Stop and remove both containers"
sudo docker container stop $SERVER_NAME $CLIENT_NAME
sudo docker container rm $SERVER_NAME $CLIENT_NAME
sudo docker image rm $IMAGE_NAME

echo -e "\n\n==== Remove $SENT_FILE and $RECEIVED_FILE"
rm -f $SENT_FILE $RECEIVED_FILE
echo "==== DONE"

# linux-docker-homework

`test-send-receive.sh` is the testing script demonstrating how two Docker containers can send and receive data from each other.
## Features:
* if the $IMAGE_NAME.tar.gz is found in the current directory - it is loaded into docker (speeds up the test a lot)
* if there is no image archive - the script builds it from the Dockerfile and saves the image archive
* the script runs two containers (client and server) and executes the corresponding netcat script inside them
* `netcat-server.sh` starts listening on TCP port 80 and waits for transmission
* `netcat-client.sh` accepts server IP as an argument, creates a 10Mb file of random data, and tries to send it to the server
* then `netcat-client.sh` compares sent and received files, and if there are no diff - test considered passed
* the final step is to clean the working directory, stop and remove both containers, delete the image from docker, and delete the previously created network

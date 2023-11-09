#!/bin/sh

# 1st argument of the script is server IP
SERVER_IP=$1

echo "Using dd to generate 10M file of random data ..."
dd if=/dev/random of=./file-to-send bs=1M count=10
nc -N $SERVER_IP 80 < file-to-send


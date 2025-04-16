#! /bin/sh

set -e

KEY_FILE=${KEY_FILE:-"key.bin"}

if [ ! -f $KEY_FILE ]; then
	echo "Error: key $KEY_FILE does not exists!"
	echo "Generate one with \"openssl rand 32 > key.bin\" and then"
	echo "export it with \"export KEY_FILE=your-path/to-the/key.bin\""
	echo "Exiting."
	exit 1
fi

# 1. build the http server
go build  -o http-echo -ldflags "-w -extldflags '-static'" -tags netgo http-echo.go

# 2. encrypt the http server
openssl enc -aes-256-cfb -pbkdf2 -kfile $KEY_FILE -in http-echo -out http-echo.enc

# 3. push the container
if [ -n "$DOCKER_REPO" ]; then
	podman build -t $DOCKER_REPO .
	podman push $DOCKER_REPO
fi
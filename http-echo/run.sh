#! /bin/sh

set -e

KEY_FILE=${KEY_FILE:-"key.bin"}

LOC=$(realpath $0)
DIR=$(dirname $LOC)

if [ ! -f $KEY_FILE ]; then
	echo "Error: key $KEY_FILE does not exists!"
	echo "Generate one with \"openssl rand 32 > key.bin\" and then"
	echo "export it with \"export KEY_FILE=your-path/to-the/key.bin\""
	echo "Exiting."
	exit 1
fi

# 1. build the http server
go build  -o $DIR/http-echo -ldflags "-w -extldflags '-static'" -tags netgo $DIR/http-echo.go

# 2. encrypt the http server
openssl enc -aes-256-cfb -pbkdf2 -kfile $KEY_FILE -in $DIR/http-echo -out $DIR/http-echo.enc

# 3. push the container
if [ -n "$DOCKER_REPO" ]; then
	podman build -t $DOCKER_REPO $DIR
	podman push $DOCKER_REPO
fi
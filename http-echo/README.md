# Build the http server

Build the code to generate a container image.

1. Generate a key if you don't have one with `openssl rand 32 > key.bin`
2. export the key `export KEY_FILE=your-path/to-the/key.bin`
3. Define the repo where to push the container `export DOCKER_REPO=quay.io/confidential-devhub/http-echo:latest`
4. run `./run.sh`

This will create an http-echo server that has 2 binaries: an encrypted http-echo in `/app-attestation` and a plaintext one in `/app`. The former will be used by `../cloud.yaml` and the latter by `../on-prem.yaml` since they respectively run in untrusted and trusted environments.
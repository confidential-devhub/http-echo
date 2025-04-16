#! /bin/sh

set -e

MODEL_DECRYPTION_KEY=${MODEL_DECRYPTION_KEY:-"workload-key/key.bin"}

if [ "$ATTESTATION" = "1" ]; then
    cd /app-attestation

    echo "#### Content of /app-attestation ####"
    echo "+ ls /app-attestation"
    ls /app-attestation

    echo

    echo "#### Fetching the key from trustee... ####"
    echo "+ curl -L http://127.0.0.1:8006/cdh/resource/default/$MODEL_DECRYPTION_KEY -o key.bin"
    curl -L http://127.0.0.1:8006/cdh/resource/default/$MODEL_DECRYPTION_KEY -o key.bin

    echo

    echo "#### Decrypting the workload ####"
    echo "+ openssl enc -d -aes-256-cfb -pbkdf2 -kfile key.bin -in http-echo.enc -out http-echo.dec"
    openssl enc -d -aes-256-cfb -pbkdf2 -kfile key.bin -in http-echo.enc -out http-echo.dec

    echo

    chmod +x http-echo.dec
    echo "./http-echo.dec"
    ./http-echo.dec
else
    cd /app

    echo "#### Content of /app ####"
    echo "+ ls /app"
    ls /app

    echo

    echo "./http-echo"
    ./http-echo
fi


FROM golang

RUN mkdir -p /app
RUN mkdir -p /app-attestation

# copy encrypted server
COPY http-echo.enc /app-attestation
# copy plaintext server for when we are not using attestation
COPY http-echo /app
# entrypoint
COPY run_server.sh /

EXPOSE 8080 8888
ENTRYPOINT ["/run_server.sh"]
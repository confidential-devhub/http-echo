# Http-echo autoscaler

This is a simple application that simulates horizontal scaling.

The http-echo pod is configured to simulate a server running a memory-intensive workload, where at each incoming request, the server internally allocates some amount of memory and prints out the name of the pod that handled the request. The server is also configured to not overstress the pod otherwise it would be `OOMKilled`, so the memory stress by default is set to 80% of the limit.

This is useful to simulate autoscaling policies aimed to automatically increase the pod deployment if there is too much memory stress in the pod.

There are two deployments available: `prem.yaml` which for the cloud-bursting use case scales horizontally to occupy the whole cluster memory, and then `cloud.yaml` which runs the same pod in a Confidential Container and unlocks the pod only if attestation is succesful.

## Considerations:

1. key.bin must be uploaded in the Trustee.
2. before running count_calls.sh you must have logged in with `oc`

## Deployment variables

* `ATTESTATION`: enable with "1". If used, `http-echo.enc` will be decrypted by using a key fetched by Trustee. Default is "0".
* `MODEL_DECRYPTION_KEY`: used only if `ATTESTATION=1`, the key to fetch from Trustee. Default is "workload-key/key.bin".
* `REQUEST_MEMORY_FOOTPRINT`: how many MB to allocate in memory for each client request received. Default is 100 MB.
* `MAX_MEMORY_STRESS_PERC`: how much memory is it allowed to allocate, given the memory limit of the pod

## Run

1. Either build your own http-echo image by running `./http-echo/run.sh`, or use `quay.io/confidential-devhub/http-echo:latest`. If you use the `cofidential-devhub` image, the model is encrypted using this key: https://people.redhat.com/~eesposit/key.bin
1. Apply your KEDA policy
2. Modify the env vars in `cloud.yaml` and then apply it
   1. For cloud bursting: set the ip in `cloud.yaml` line 25. This is because the worker node has two IPs: node IP (which is its internal IP) and VPN client IP (to connect with Azure). By default, the CoCo pod and CVM underneath are configured to talk with the node IP, which works if the pod is in the same environment. But since the pod is on Azure, the remote ip has to be changed.
3. Modify the env vars in `prem.yaml` and then apply it
4. Apply `network.yaml`
   1. If the route is unreachable, add the route to /etc/hosts: `<your ip>      my-web-app-route-default.apps.coco2410.kata.com`
5. Run `count_calls.sh` and observe the result. Otherwise try manually:
   1. `APP_URL=$(oc get routes/my-web-app-route -o jsonpath='{.spec.host}')`:
   2. `curl $APP_URL` and notice how the ip address changes
	```
	# curl $APP_URL
	Service handled by pod on-prem-deployment-68fcf4d4f-qw4rj
	# curl $APP_URL
	Service handled by pod on-prem-deployment-68fcf4d4f-g5nff
	```
### Limitations

The pod memory footprint only scales up, and never down.

## Cloud-bursting use case

In the cloud-bursing use case, we want the on-prem deployment (secure environment so no attestation) to only scale horizontally, and the cloud deployment (which will be activated only when the cluster is full) to use attestation.
# DSMLP Custom Image Help Guide

<!-- One Paragraph of project description goes here -->

## Launching a Container

```bash
ssh USER@dsmlp-login.ucsd.edu
./launch-custom.sh
```

| Option   | Description                                  | Example               |
|----------|----------------------------------------------|-----------------------|
| -c N     | Adjust # CPU cores                           | -c 8                  |
| -g N     | Adjust # GPU cards                           | -g 2                  |
| -m N     | Adjust # GB RAM                              | -m 64                 |
| -i IMG   | Docker image name                            | -i nvidia/cuda:latest |
| -e ENTRY | Docker image ENTRYPOINT/CMD                  | -e /run_jupyter.sh    |
| -n N     | Request specific cluster node (1-10)         | -n 7                  |
| -v       | Request specific GPU (gtx1080ti,k5200,titan) | -v k5200              |
| -b       | Request background pod                       | (see below)           |

## Destoying the Container

On dsmlp-login:

```bash
kubectl get pods
kubectl delete pod <pod-id>
```

## Build

```bash
git clone https://github.com/davidzyx/datahub-docker.git
cd datahub-docker
docker build . -t TAG
docker push TAG
```

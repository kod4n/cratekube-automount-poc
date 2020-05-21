# cratekube-automount-poc
POC for the cratekube automount component

## How this works
This project contains a Dockerfile used to build the automount-serivce responsible for doing mounting via CIFS.
The entrypoint to the application requires three environment variables to be available: `AUTOFS_USER`, `AUTOFS_PASS`,
and `CONFIG_LOCATION`.

The `CONFIG_LOCATION` environment variable should be a url to mount configuration template file.  
The file should contain any available mounts for the autofs service.  Below is an example configuration file line:
```
mountname -fstype=cifs,<any additional options here>,username={{ .username }},password={{ .password }} ://filer/path
```

The `AUTOFS_USER` and `AUTOFS_PASS` environment variables will be used to update the configuration template file with
the correct user name and password options.

## Prerequisites
In order to use the automount-service container the host running the container will need to have the autofs4 kernel
module installed.

## Deploying in Kubernetes
The [deployments](deployments) directory contains yaml specifications needed to run the automount service and test that
mounts work.  The [secret.yaml](deployments/secret.yaml) file should be updated with the correct user and password to be
used for the CIFS mounts.  The [daemonset.yaml](deployments/daemonset.yaml) file should also be updated with a correct 
DNS search and image version.

## How this service was tested
An RKE cluster was used to test this automount implementation, the cluster contained the following node config:
- 1 master node with roles `controlplane` and `etcd`
- 2 worker nodes with role `worker`

Once the cluster was available the k8s yaml files were applied in the following order:
- secret.yaml
- pv.yaml
- pvc.yaml
- daemonset.yaml
- hello-world.yaml

After the services start the automount can be tested by execing into the hello-world pod and attempting to change directory
into `/auto/<mountname>`.  If the credentials supplied in the `secret.yaml` file CIFS access the mount will occur and data
can be viewed and modified.

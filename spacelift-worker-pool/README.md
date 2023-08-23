# Spacelift Workerpool Helm Chart

This folder contains a Helm chart for deploying a [Spacelift Worker Pool](https://docs.spacelift.io/concepts/worker-pools) on Kubernetes. The chart deploys the worker pool as a StatefulSet containing two containers:

- launcher - the Spacelift launcher that is responsible for receiving runs from Spacelift and
  executing them in Docker containers.
- dind - a Docker container that provides a Docker daemon for the Spacelift launcher to use.

## Quick Start

Follow the instructions [here](https://docs.spacelift.io/concepts/worker-pools) to create a
new worker pool, generating a private key and token.

Next, add our Helm chart repo and update your local chart cache:

```shell
helm repo add spacelift https://downloads.spacelift.io/helm
helm repo update
```

Assuming your key and token are stored in the `SPACELIFT_PK` and `SPACELIFT_TOKEN` environment
variables, you can install the chart using the following command:

```shell
helm upgrade spacelift-worker spacelift/spacelift-worker --install --set "credentials.token=$SPACELIFT_TOKEN,credentials.privateKey=$SPACELIFT_PK"
```

Read the rest of this page to find out how to configure various other options.

## Docker in Docker

This chart uses [Docker in Docker](https://hub.docker.com/_/docker) to provide a Docker daemon
for the launcher. The `dind` container needs a privileged [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
to work. Please make sure this is acceptable to you before deploying it to your own clusters.

### Does this work with containerd

Yes - the Docker in Docker approach used by this chart should still work even if your cluster nodes are not using dockershim. The reason this works is because we run a Docker daemon in a side-car container rather than relying on the Kubernetes node's runtime.

## Image Version

The `launcher.image.tag` is set to `latest` by default in this chart. We rely on this behavior
to automatically roll out new versions of the launcher. Pinning this to a specific version
may eventually cause your private launchers to stop working.

## Authentication

To authenticate with Spacelift, you need to set the `SPACELIFT_TOKEN` and `SPACELIFT_POOL_PRIVATE_KEY`
environment variables. By default, this chart will create a Kubernetes secret for you and configure
both environment variables if you set the `credentials.token` and `credentials.privateKey`
variables.

If you want to provide your credentials another way, set `credentials.create` to `false`, and
use the `launcher.extraEnv` value to provide the variables yourself. For example:

```yaml
credentials:
  create: false

launcher:
  extraEnv:
    - name: "SPACELIFT_TOKEN"
      value: "my-token"
    - name: "SPACELIFT_POOL_PRIVATE_KEY"
      valueFrom:
        secretKeyRef:
          name: spacelift-secret
          key: privateKey
```

## Storage

By default this chart configures the launcher pods to use `emptyDir` for storage. If you decide
to use `emptyDir`, please be aware that there needs to be enough space available on your
Kubernetes nodes for the worker to use. If your nodes run low on disk space the worker pods
may be evicted.

Because of this, the chart provides other ways to configure storage for the launcher:

- Using a [volume template](#volume-template) (recommended).
- Using a [volume claim template](#volume-claim-template).

### Volume Template

The recommended way to configure your launchers is using a [generic ephemeral volume](https://kubernetes.io/docs/concepts/storage/ephemeral-volumes/#generic-ephemeral-volumes).
This means that the volume follows the same lifetime as the launcher pod, and is automatically
removed when a launcher is destroyed.

The following example shows how to configure a 100Gi GP2 volume for storage:

```yaml
storageVolume:
  ephemeral:
    volumeClaimTemplate:
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: "gp2"
        resources:
          requests:
            storage: 100Gi
```

### Volume Claim Template

Another option is to use a volume claim template. This adds a volume claim template to the
launcher StatefulSet, allowing a volume to automatically be provisioned. The downside to this
approach is that your volume will not automatically be deleted when pods are deleted (for example,
when scaling down), and you will have to manually delete any volumes yourself.

Please note that volume claim templates are only supported when using a StatefulSet rather
than a Deployment.

The following example shows how to configure a 100Gi GP2 volume for storage:

```yaml
useStatefulSet: true

storageVolumeClaimTemplateSpec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: "gp2"
  resources:
    requests:
      storage: 100Gi
```

### Extra volumes

It is possible to add additional volumes to the Deployment or Stateful set by defining the `volumes`
value and attach it to launcher container with `launcher.extraVolumeMounts`. This can for instance be
useful to mount credentials for docker login if necessary.

Example mounting a secret `config.json` to `/opt/docker`:

```yaml
launcher:
  extraVolumeMounts:
  - name: secret-volume
    mountPath: /opt/docker/config.json
    subPath: config.json

volumes:
- name: secret-volume
  secret:
    secretName: very-secret
```

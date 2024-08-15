# Helm chart spacelift-workerpool-controller

This chart allows to deploy the Spacelift workerpool controller for kubernetes native workers.

## Quick Start

Add our Helm chart repo and update your local chart cache:

```shell
helm repo add spacelift https://downloads.spacelift.io/helm
helm repo update
```

You can then install the controller using this chart 

```shell
helm upgrade spacelift-workerpool-controller spacelift/spacelift-workerpool-controller --install --set spacelift-promex.enabled=false
```

You are now ready to create a worker pool and start scheduling some runs.
Follow the instructions on the [user-documentation](https://docs.spacelift.io/concepts/worker-pools.html#kubernetes) for more detailed instructions.

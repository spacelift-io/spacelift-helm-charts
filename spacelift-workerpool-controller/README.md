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
helm upgrade spacelift-workerpool-controller spacelift/spacelift-workerpool-controller --install
```

You are now ready to create a worker pool and start scheduling some runs.
Follow the instructions on the [user-documentation](https://docs.spacelift.io/concepts/worker-pools.html#kubernetes) for more detailed instructions.

## Maintaining CRDs and chart versions

CRD generation is no longer handled by CI. Before opening a PR, update the raw CRDs and regenerate the chart templates locally:

1. Paste the raw CRDs into `config/crd/bases/`.
2. Set `CHART_VERSION` to the desired version (edit the value in `Makefile` or pass it as an environment variable).
3. Run:

```shell
make codegen-helm
```

Then commit the changes and open a PR.

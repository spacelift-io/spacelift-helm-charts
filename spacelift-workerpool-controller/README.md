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

## Rolling Upgrades and Pod Disruption Budgets

When performing rolling Kubernetes upgrades (e.g., EKS node AMI updates), you can protect in-flight
runs from disruption by enabling the Pod Disruption Budget (PDB):

```yaml
pdb:
  enabled: true
  minAvailable: "100%"
```

This creates a PDB that targets all worker pods managed by the controller. With `minAvailable: "100%"`,
`kubectl drain` will not evict any worker pod that is currently executing a run. The drain will proceed
once runs complete and pods terminate naturally.

### Configuration Options

| Value | Description | Default |
|-------|-------------|---------|
| `pdb.enabled` | Enable PDB for worker pods | `false` |
| `pdb.minAvailable` | Minimum available worker pods (number or percentage) | - |
| `pdb.maxUnavailable` | Maximum unavailable worker pods (number or percentage) | - |

Only one of `minAvailable` or `maxUnavailable` should be set.

### Namespace Considerations

The PDB is namespace-scoped. When `controllerManager.namespaces` is configured, a PDB is created in
each specified namespace. Otherwise, the PDB is created in the release namespace. If you run in
cluster-wide mode and have WorkerPools in multiple namespaces, you may need to create additional PDBs
manually in those namespaces.

### Notes

- The PDB targets worker pods using the `workers.spacelift.io/workerpool` label, which is
  automatically applied to all worker pods by the controller.
- A PDB with no matching pods (e.g., when no runs are active) is a no-op and will not block drains.
- The PDB only affects voluntary disruptions (e.g., `kubectl drain`). It does not affect direct pod
  deletions or involuntary disruptions like node crashes.

## Maintaining CRDs and chart versions

CRD generation is no longer handled by CI. Before opening a PR, update the raw CRDs and regenerate the chart templates locally:

1. Paste the raw CRDs into `config/crd/bases/`.
2. Set `CHART_VERSION` to the desired version (edit the value in `Makefile` or pass it as an environment variable).
3. Run:

```shell
make codegen-helm
```

Then commit the changes and open a PR.

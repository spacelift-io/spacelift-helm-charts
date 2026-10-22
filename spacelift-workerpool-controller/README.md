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

## Extra environment variables

`controllerManager.manager.extraEnv` and `controllerManager.manager.envFrom` inject additional
environment variables into the controller container, the same way `launcher.extraEnv` and
`launcher.envFrom` do for the worker pool chart.

The controller is a Go process, so this is how you send its Spacelift API calls through an HTTP
proxy. Set `HTTP_PROXY` and `HTTPS_PROXY` to the proxy URL, and set `NO_PROXY` so in-cluster
traffic (the Kubernetes API, and anything under `.svc` / `.cluster.local`) stays direct. Without
`NO_PROXY`, the controller will also try to reach the API server through the proxy.

```yaml
controllerManager:
  manager:
    extraEnv:
      - name: HTTP_PROXY
        value: http://proxy.example.com:8080
      - name: HTTPS_PROXY
        value: http://proxy.example.com:8080
      - name: NO_PROXY
        value: localhost,127.0.0.1,.svc,.cluster.local
```

To load every key from a Secret or ConfigMap instead:

```yaml
controllerManager:
  manager:
    envFrom:
      - secretRef:
          name: spacelift-controller-proxy
```

Entries in `extraEnv` are appended after the variables the chart sets itself
(`CONTROLLER_NAMESPACE`, `KUBERNETES_CLUSTER_DOMAIN`, and `GODEBUG` when
`controllerManager.enforceFips140` is true). An explicit `env` entry takes precedence over the
same key coming from `envFrom`.

## Rolling Upgrades and Pod Disruption Budgets

Two separate PDBs are available: `pdb` protects the **worker** pods that execute runs, and
`controllerManager.pdb` protects the **controller** pods themselves. Both are disabled by default.

### Worker pods

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

#### Configuration Options

| Value | Description | Default |
|-------|-------------|---------|
| `pdb.enabled` | Enable PDB for worker pods | `false` |
| `pdb.minAvailable` | Minimum available worker pods (number or percentage) | - |
| `pdb.maxUnavailable` | Maximum unavailable worker pods (number or percentage) | - |

Exactly one of `minAvailable` or `maxUnavailable` must be set when `pdb.enabled: true`. Setting
both, or neither, fails the install/upgrade with a template error.

#### Namespace Considerations

The PDB is namespace-scoped. When `controllerManager.namespaces` is configured, a PDB is created in
each specified namespace. Otherwise, the PDB is created in the release namespace. If you run in
cluster-wide mode and have WorkerPools in multiple namespaces, you may need to create additional PDBs
manually in those namespaces.

#### Notes

- The PDB targets worker pods using the `workers.spacelift.io/workerpool` label, which is
  automatically applied to all worker pods by the controller.
- A PDB with no matching pods (e.g., when no runs are active) is a no-op and will not block drains.
- The PDB only affects voluntary disruptions (e.g., `kubectl drain`). It does not affect direct pod
  deletions or involuntary disruptions like node crashes.

### Controller pods

The controller runs active/passive under leader election: whatever the replica count, exactly one pod
holds the lease and does the work.

```yaml
controllerManager:
  replicas: 2
  pdb:
    enabled: true
```

| Value | Description | Default |
|-------|-------------|---------|
| `controllerManager.pdb.enabled` | Enable PDB for controller pods | `false` |
| `controllerManager.pdb.maxUnavailable` | Maximum unavailable controller pods | `1` |
| `controllerManager.pdb.minAvailable` | Minimum available controller pods | - |

The controller PDB is always created in the release namespace, alongside the Deployment, regardless
of `controllerManager.namespaces`.

## Maintaining CRDs and chart versions

CRD generation is no longer handled by CI. Before opening a PR, update the raw CRDs and regenerate the chart templates locally:

1. Paste the raw CRDs into `config/crd/bases/`.
2. Set `CHART_VERSION` to the desired version (edit the value in `Makefile` or pass it as an environment variable).
3. Run:

```shell
make codegen-helm
```

Then commit the changes and open a PR.

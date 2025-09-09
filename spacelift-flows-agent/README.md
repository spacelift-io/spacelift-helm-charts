# Spacelift Flows Agent Helm Chart

This Helm chart deploys a Spacelift Flows Agent pool to a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+

## Installation

1. Create a secret containing your agent pool credentials:

```bash
kubectl create secret generic spacelift-flows-agentpool \
  --from-literal=token=your-agent-pool-token \
  --from-literal=pool-id=your-agent-pool-id
```

2. Add the required configuration to your values file:

```yaml
agent:
  endpoint: "https://mycompany.spacelift.sh"
  gatewayEndpoint: "ws://spacelift-flows-gateway.default.svc.cluster.local:8080"
  # Optional: customize secret name and keys
  # secretName: "spacelift-flows-agentpool"
  # poolTokenKey: "token"
  # poolIdKey: "pool-id"
```

3. Install the chart:

```bash
helm repo add spacelift https://downloads.spacelift.io/helm
helm repo update

helm install spacelift-flows-agent spacelift/spacelift-flows-agent -f your-values.yaml
```

## Configuration

| Parameter                    | Description                              | Default                                                  |
|------------------------------|------------------------------------------|----------------------------------------------------------|
| `image.repository`           | Agent image repository                   | `public.ecr.aws/u4b1s0s6/spacelift-flows-agent`          |
| `image.tag`                  | Agent image tag                          | `7eb57f0730fc1882172c82665d5e850c09fb863c`               |
| `image.pullPolicy`           | Image pull policy                        | `IfNotPresent`                                           |
| `replicaCount`               | Number of agent replicas                 | `1`                                                      |
| `agent.gatewayEndpoint`      | Gateway WebSocket endpoint               | `ws://spaceflows-gateway.default.svc.cluster.local:8080` |
| `agent.secretName`           | Secret containing agent pool credentials | `spacelift-flows-agentpool`                              |
| `agent.poolTokenKey`         | Key in secret for pool token             | `token`                                                  |
| `agent.poolIdKey`            | Key in secret for pool ID                | `pool-id`                                                |
| `agent.poolSize`             | The size of the agent pool               | `3`                                                      |
| `agent.endpoint`             | Spaceflows API endpoint                  | `https://your-spaceflows-instance.com`                   |
| `agent.executor`             | Executor type                            | `kubernetes`                                             |
| `agent.kubernetes.namespace` | Kubernetes namespace for executor pods   | `default`                                                |
| `jsExecutorImage.repository` | JS executor image repository             | `471112651138.dkr.ecr.eu-central-1.amazonaws.com/flows`  |
| `jsExecutorImage.tag`        | JS executor image tag                    | `k8s-js-executor-3`                                      |
| `resources.requests.memory`  | Memory request                           | `256Mi`                                                  |
| `resources.requests.cpu`     | CPU request                              | `100m`                                                   |
| `resources.limits.memory`    | Memory limit                             | `512Mi`                                                  |
| `resources.limits.cpu`       | CPU limit                                | `500m`                                                   |
| `serviceAccount.create`      | Create service account                   | `true`                                                   |
| `rbac.create`                | Create RBAC resources                    | `true`                                                   |
| `otel.enabled`               | Enable OpenTelemetry                     | `false`                                                  |
| `otel.collectorEndpoint`     | OTEL collector endpoint                  | `http://otel-collector:4317`                             |

## RBAC

The chart creates the following RBAC resources by default:

- ServiceAccount for the agent
- Role with permissions to manage pods (create, get, list, delete, watch)
- RoleBinding to associate the ServiceAccount with the Role

## Examples

### Basic installation with required configuration:

First create the secret:
```bash
kubectl create secret generic spacelift-flows-agentpool \
  --from-literal=token=your-agent-pool-token \
  --from-literal=pool-id=your-agent-pool-id
```

Then use this values file:
```yaml
agent:
  endpoint: "https://mycompany.spacelift.sh"
  gatewayEndpoint: "ws://spacelift-flows-gateway.default.svc.cluster.local:8080"
```

### With custom resources:

```yaml
agent:
  endpoint: "https://mycompany.spacelift.sh"

resources:
  requests:
    memory: "512Mi"
    cpu: "200m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

### With multiple replicas:

```yaml
replicaCount: 3

agent:
  endpoint: "https://mycompany.spacelift.sh"
```

### With custom secret name:

```yaml
agent:
  endpoint: "https://mycompany.spacelift.sh"
  secretName: "my-custom-secret"
  poolTokenKey: "agent-token"
  poolIdKey: "agent-pool-id"
```

## Uninstall

```bash
helm uninstall my-spacelift-flows-agent
```
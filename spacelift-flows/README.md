# Spacelift Flows Helm Chart

## 📦 Chart Migration

**This chart has been merged into the Spacelift Self-Hosted chart, in [spacelift-io/spacelift-self-hosted-helm-chart](https://github.com/spacelift-io/spacelift-self-hosted-helm-chart).**

Updates and support for Flows will be provided in the new repository. Flows is now deployed by the `spacelift-self-hosted` chart when `flows.enabled` is set to `true`. The versions of `spacelift-flows` that were already published stay available in the Helm repository, [https://downloads.spacelift.io/helm](https://downloads.spacelift.io/helm), but they won't get new releases.

The Flows agent chart has not moved. It is still [spacelift-flows-agent](../spacelift-flows-agent) in this repository.

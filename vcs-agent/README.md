# Spacelift VCS Agent Helm Chart

This folder contains a Helm chart for deploying a [Spacelift VCS Agent](https://docs.spacelift.io/concepts/vcs-agent-pools) on Kubernetes. The chart deploys the VCS Agent as a Deployment.

## Quick Start

Follow the instructions [here](https://docs.spacelift.io/concepts/vcs-agent-pools#create-the-vcs-agent-pool) to create a
new VCS Agent pool, generating a token.

Next, add our Helm chart repo and update your local chart cache:

```shell
helm repo add spacelift https://downloads.spacelift.io/helm
helm repo update
```

Assuming your token, VCS endpoint and vendor are stored in the `SPACELIFT_VCS_AGENT_POOL_TOKEN`, `SPACELIFT_VCS_AGENT_TARGET_BASE_ENDPOINT` and `SPACELIFT_VCS_AGENT_VENDOR` environment
variables, you can install the chart using the following command:

```shell
helm upgrade vcs-agent spacelift/vcs-agent --install --set "credentials.token=$SPACELIFT_VCS_AGENT_POOL_TOKEN,credentials.endpoint=$SPACELIFT_VCS_AGENT_TARGET_BASE_ENDPOINT,credentials.vendor=$SPACELIFT_VCS_AGENT_VENDOR"
```

## Image Version

The `image.tag` is set to `latest` by default in this chart. We rely on this behavior
to automatically roll out new versions of the VCS Agent.

## Authentication

To authenticate with Spacelift, you need to set the `SPACELIFT_VCS_AGENT_POOL_TOKEN`, `SPACELIFT_VCS_AGENT_TARGET_BASE_ENDPOINT` and `SPACELIFT_VCS_AGENT_VENDOR`
environment variables. By default, this chart will create a Kubernetes secret for you and configure both environment variables if you set the `credentials.token`, `credentials.endpoint` and `credentials.vendor`
variables.

If you want to provide your credentials another way, set `credentials.create` to `false`, and
use the `vcs-agent.extraEnv` value to provide the variables yourself. For example:

```yaml
credentials:
  create: false

vcsagent:
  extraEnv:
    - name: "SPACELIFT_VCS_AGENT_POOL_TOKEN"
      valueFrom:
        secretKeyRef:
            name: spacelift-secret
            key:  token
    - name: "SPACELIFT_VCS_AGENT_TARGET_BASE_ENDPOINT"
      value: "https://gitlab.myorg.com"
    - name: "SPACELIFT_VCS_AGENT_VENDOR"
      value: "vcs-vendor"
```

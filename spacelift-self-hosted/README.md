# Helm chart spacelift-self-hosted

This chart allows to deploy an instance of Spacelift in a self-hosted environment.

> [!NOTE]
> From Spacelift v6.4.0 on, the drain runs the cron scheduler itself and this chart
> no longer deploys a standalone `scheduler` workload. On older versions the workload
> is still deployed, so upgrading the chart on its own is safe. There is nothing to
> configure either way: the version is taken from the tag of `shared.image`. If that
> tag is not of the form `vX.Y.Z`, the chart keeps deploying the workload.

## Quick Start

Depending on your environment, you can check the [guides here](https://docs.spacelift.io/self-hosted/latest/installing-spacelift/reference-architecture/guides) 
for more details about how to use this chart.

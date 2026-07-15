# Helm chart spacelift-self-hosted

This chart allows to deploy an instance of Spacelift in a self-hosted environment.

> [!IMPORTANT]
> This chart no longer deploys the standalone scheduler: the cron scheduler runs
> inside the drain (`DRAIN_SCHEDULER_ENABLED`, on by default since Self-Hosted
> v6.3.0). It requires Self-Hosted v6.2.0 or newer — on v6.2.x, set
> `DRAIN_SCHEDULER_ENABLED: "true"` in the drain secret. Upgrading the chart
> deletes any existing scheduler Deployment.

## Quick Start

Depending on your environment, you can check the [guides here](https://docs.spacelift.io/self-hosted/latest/installing-spacelift/reference-architecture/guides) 
for more details about how to use this chart.

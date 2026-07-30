# Helm chart spacelift-self-hosted

This chart allows to deploy an instance of Spacelift in a self-hosted environment.

> [!IMPORTANT]
> This chart no longer deploys the standalone scheduler: the cron scheduler runs
> inside the drain. It requires Self-Hosted **v6.2.0 or newer**; from v6.4.0 on,
> the drain always runs it. Nothing has to be configured — on v6.2.x and v6.3.x
> the chart turns the embedded scheduler on for you.
>
> Upgrading the chart deletes any existing scheduler Deployment. A leftover
> `scheduler` section in your values file is accepted but ignored, so the upgrade
> won't fail — it can be deleted at any time.

## Quick Start

Depending on your environment, you can check the [guides here](https://docs.spacelift.io/self-hosted/latest/installing-spacelift/reference-architecture/guides) 
for more details about how to use this chart.

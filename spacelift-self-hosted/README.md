# Helm chart spacelift-self-hosted

This chart allows to deploy an instance of Spacelift in a self-hosted environment.

> [!NOTE]
> From Spacelift v6.4.0 on, the drain runs the cron scheduler itself and this chart
> no longer deploys a standalone `scheduler` workload. On older versions the workload
> is still deployed, so upgrading the chart on its own is safe. Normally there is
> nothing to configure: the version is taken from the backend image tag, which
> defaults to the chart's `appVersion`, and if that tag is not of the form `vX.Y.Z`
> the chart keeps deploying the workload. Set `scheduler.enabled` to `true` or
> `false` to decide it yourself instead.

## Backend image

By default the chart pulls `oci.spacelift.io/deploy/backend:<appVersion>`.
Set `shared.backendImage` to change the registry, repository, tag or digest, and
`shared.backendImage.fips` to use the FIPS 140 build. Pulling from
`oci.spacelift.io` needs credentials: set them with `shared.imagePullSecrets`.

`shared.image` still works and takes a full image reference, but it is deprecated.
While it is set, the chart ignores `shared.backendImage`.

## Launcher image

Kubernetes workers run the launcher image that the backend reads from
`LAUNCHER_IMAGE` and `LAUNCHER_IMAGE_TAG`. Set `shared.launcherImage.enabled` to
`true` to let the chart set both on the server and drain, by default
to `oci.spacelift.io/deploy/launcher` and the chart's `appVersion`. These
values win over the same keys in your secrets. `shared.launcherImage` takes the
same `registry`, `repository`, `tag` and `fips` keys as `shared.backendImage`, but
no digest: the backend joins the two values as `image:tag`.

## Quick Start

Depending on your environment, you can check the [guides here](https://docs.spacelift.io/self-hosted/latest/installing-spacelift/reference-architecture/guides) 
for more details about how to use this chart.

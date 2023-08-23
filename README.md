# Spacelift Helm Chart Repository

This repository contains Helm Charts for Kubernetes Private Worker Pool setup and VCS Agent setup. You can read the documentation about the Private Worker concept from [here](https://docs.spacelift.io/concepts/worker-pools), and you can read the documentation about the VCS Agents from [here](https://docs.spacelift.io/concepts/vcs-agent-pools).

## Documentation for the Helm Charts

Within each folder in this repository there is additional documentation for each chart.

For installation of the Worker Pool Helm Chart you can refer to the relative [documentation](spacelift-worker-pool/README.md).

For installation of the VCS Agent Helm Chart, you can refer to the relative [documentation](vcs-agent/README.md).

## Development

### Publishing the Chart

To publish a new version of the chart, create a new release with a tag in the format `v<version>`, for example `v0.0.1`. This will automatically trigger the workflow to publish the chart.
Both charts in this repository will published at the same time and they will have the same version number.

# Helm chart spacelift-prometheus-exporter

This chart allows to deploy the Spacelift prometheus exporter.

## Quick Start

Add our Helm chart repo and update your local chart cache:

```shell
helm repo add spacelift https://downloads.spacelift.io/helm
helm repo update
```

Create a secret with your spacelift api key secret
```shell
kubectl create secret generic spacelift-api-key --from-literal=SPACELIFT_PROMEX_API_KEY_SECRET="{yourApiKeySecret}"
```

You can then install the controller using this chart
```shell
helm upgrade spacelift-prometheus-exporter spacelift/spacelift-promex --install \
    --set spacelift.apiEndpoint="https://{yourAccount}.app.spacelift.io" \
    --set spacelift.apiKeyId="{yourApiToken}" \
    --set spacelift.apiKeySecretName="spacelift-api-key"
```

Follow the instructions on the [user-documentation](https://github.com/spacelift-io/prometheus-exporter) for more detailed instructions.

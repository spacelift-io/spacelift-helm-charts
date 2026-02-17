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
    --set apiEndpoint="https://{yourAccount}.app.spacelift.io" \
    --set apiKeyId="{yourApiToken}" \
    --set apiKeySecretName="spacelift-api-key"
```

## Custom CA Certificate

If your Spacelift endpoint uses a certificate chain not covered by system CAs, you can inject a custom CA certificate from a Kubernetes secret:

```shell
kubectl create secret generic spacelift-ca-cert --from-file=ca.crt=/path/to/your/ca.crt
```

```shell
helm upgrade spacelift-prometheus-exporter spacelift/spacelift-promex --install \
    --set apiEndpoint="https://{yourAccount}.app.spacelift.io" \
    --set apiKeyId="{yourApiToken}" \
    --set apiKeySecretName="spacelift-api-key" \
    --set caCert.enabled=true \
    --set caCert.secretName="spacelift-ca-cert"
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `caCert.enabled` | Enable custom CA certificate | `false` |
| `caCert.secretName` | Name of the secret containing the CA certificate | `""` |
| `caCert.secretKey` | Key within the secret holding the PEM-encoded certificate | `"ca.crt"` |
| `caCert.mountPath` | Directory to mount the certificate into | `"/certs"` |

Follow the instructions on the [user-documentation](https://github.com/spacelift-io/prometheus-exporter) for more detailed instructions.

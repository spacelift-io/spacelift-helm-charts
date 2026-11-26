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

## OIDC API keys

If your Spacelift API key is an OIDC key (key ID of the form `oidc::<issuer>::<key-id>`), the chart can mount a rotating projected service-account token instead of using a static secret. The exporter reads it through `SPACELIFT_PROMEX_API_KEY_SECRET_FILE` and picks up rotations without restarts. This requires exporter image `v0.11.0` or newer.

```shell
helm upgrade spacelift-prometheus-exporter spacelift/spacelift-promex --install \
    --set image.tag="v0.13.0" \
    --set apiEndpoint="https://{yourAccount}.app.spacelift.io" \
    --set apiKeyId="oidc::{issuer}::{keyId}" \
    --set oidc.enabled=true \
    --set oidc.audience="{yourAudience}"
```

`apiKeySecretName` is not needed when `oidc.enabled=true`.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `oidc.enabled` | Use a projected service-account token as the API key secret | `false` |
| `oidc.audience` | Audience of the projected token (required when enabled) | `""` |
| `oidc.expirationSeconds` | Requested token lifetime | `3600` |
| `oidc.mountPath` | Directory the token is mounted into | `"/var/run/secrets/spacelift"` |
| `oidc.tokenFileName` | Token file name within the mount path | `"token"` |
| `serviceAccountName` | Service account for the pod (the token's identity) | `""` |

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

## Extra Environment Variables

You can add extra environment variables to the container via `extraEnv` and `extraEnvFrom`:

```yaml
extraEnv:
  - name: MY_ENV_VAR
    value: "some-value"
  - name: MY_SECRET_ENV_VAR
    valueFrom:
      secretKeyRef:
        name: my-secret
        key: my-key

extraEnvFrom:
  - configMapRef:
      name: my-configmap
  - secretRef:
      name: my-secret
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `extraEnv` | Extra environment variables to add to the container | `[]` |
| `extraEnvFrom` | Extra envFrom sources (ConfigMaps/Secrets) to add to the container | `[]` |

Follow the instructions on the [user-documentation](https://github.com/spacelift-io/prometheus-exporter) for more detailed instructions.

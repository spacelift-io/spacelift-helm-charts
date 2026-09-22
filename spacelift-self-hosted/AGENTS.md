# Spacelift Self-Hosted Helm Chart

## Schema Maintenance

This chart includes a `values.schema.json` file that validates values during `helm install`, `helm upgrade`, `helm lint`, and `helm template`.

**When modifying `values.yaml`:**

1. Update `values.schema.json` to reflect any new, changed, or removed fields
2. Run `helm lint spacelift-self-hosted/` to verify the schema is valid
3. Test that invalid values are rejected: `helm lint spacelift-self-hosted/ --set server.port=99999`

**Schema structure:**

- Reusable definitions are in `$defs` (serviceAccount, resources, securityContext, etc.)
- Use `$ref` to reference definitions: `"$ref": "#/$defs/annotations"`
- Set `additionalProperties: false` on objects to catch typos
- Allow null for optional objects: `"type": ["object", "null"]`

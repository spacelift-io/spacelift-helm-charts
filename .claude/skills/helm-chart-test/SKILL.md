---
name: helm-chart-test
description: Write, fix, and run helm-unittest tests for the spacelift-self-hosted chart. Applies this repo's helm-unittest conventions.
user_invocable: true
---

# /helm-chart-test [component]

Use this skill whenever the user asks to add, fix, or review helm-unittest tests, or when a change to `spacelift-self-hosted/` needs matching rendered-manifest tests.

## Scope

**This skill only applies to `spacelift-self-hosted/`.** It is the only chart in this repo wired up for helm-unittest. Charts live at the repo root (`spacelift-self-hosted/`, `spacelift-flows/`, `vcs-agent/`, ...), not under `charts/`.

If the user asks for helm-unittest tests for any other chart, say that chart has no helm-unittest setup and ask whether they want one added before writing anything.

Paths in this document are relative to the repo root.

## Argument Handling

**During feature implementation**, infer the affected templates from the diff or the requested change. Add or update focused tests for the changed rendered behavior without pausing to ask about scope, unless the requested behavior is ambiguous.

**If `[component]` is given** (e.g. `vcs-gateway`, `server`, `drain`, `scheduler`), work on the templates with that prefix and the matching test file.

**If nothing is given for a standalone task**, ask which component or template the user wants covered.

## Feature Implementation Mode

When this skill runs as part of implementing a chart change:

1. Identify the affected templates, helpers, and values from the diff or the request.
2. Read `spacelift-self-hosted/templates/_helpers.tpl` for any helper the template calls.
3. Read the nearest existing test file and mirror its style.
4. Add or update focused tests for the new or changed behavior.
5. Cover the enabled/disabled branches, value propagation, selectors, labels, annotations, containers, volumes, and service wiring the change touches.
6. Run `make -C spacelift-self-hosted test`.

Ask the user only when there are multiple plausible semantics, or when the affected templates cannot be worked out from local context.

## Chart Layout

- `spacelift-self-hosted/Chart.yaml` - chart metadata.
- `spacelift-self-hosted/values.yaml` - defaults. Top-level keys: `shared`, `server`, `drain`, `scheduler`, `vcsGateway`, `cloudSqlProxy`, `serviceAccount`, `service`, `mqttService`, `ingress`, `ingressV6`, `extraManifests`, `nameOverride`, `fullnameOverride`.
- `spacelift-self-hosted/values.schema.json` - JSON Schema validated on every render, including helm-unittest runs.
- `spacelift-self-hosted/templates/` - flat, no subdirectories. Templates are named `<component>-<kind>.yaml`, e.g. `vcs-gateway-deployment.yaml`, `server-pdb.yaml`.
- `spacelift-self-hosted/tests/` - flat, one `<topic>_test.yaml` per behavior area.
- `spacelift-self-hosted/tests/__snapshot__/` - snapshot output, currently empty.

## helm-unittest Overview

Tests are YAML files in `spacelift-self-hosted/tests/` that assert on rendered Kubernetes manifests. Each `tests[].it` case renders independently with that case's value inputs. Keep tests focused and deterministic: one behavior per test, explicit value overrides, scoped assertions.

### Repo Conventions

- First line of every test file is the schema comment:
  `# yaml-language-server: $schema=https://raw.githubusercontent.com/helm-unittest/helm-unittest/main/schema/helm-testsuite.json`
- Template references are **bare filenames** relative to `templates/`: `vcs-gateway-deployment.yaml`. The plugin also accepts a `templates/` prefix, but every existing test here omits it - match that.
- Values come from inline `set` blocks. This repo has no `tests/values/` or `ci/` values files; do not invent them.
- Tests run with `--strict`, so an unknown or misspelled field in a test file fails the run instead of being ignored.
- `values.schema.json` sets `additionalProperties: false` on objects. A `set` key that is not in the schema fails the render. If a test needs a new value, the schema must be updated too - and that is a chart change, not a test change, so flag it to the user.
- The plugin has a `--skip-schema-validation` flag. This repo does not pass it and should not start. A schema rejection means the test is setting something the chart does not accept, which is worth knowing.

### Test File Structure

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/helm-unittest/helm-unittest/main/schema/helm-testsuite.json
suite: <descriptive suite name>
templates:
  - vcs-gateway-deployment.yaml
tests:
  - it: <test case description>
    set:
      vcsGateway.enabled: true
      vcsGateway.domain: vcs-gateway.example.com
    asserts:
      - isKind:
          of: Deployment
      - equal:
          path: metadata.name
          value: spacelift-vcs-gateway
      - contains:
          path: spec.template.spec.containers[0].env
          content:
            name: MY_VAR
            value: my-value
```

Note `fullnameOverride` defaults to `spacelift`, so rendered names are `spacelift-*` rather than `RELEASE-NAME-*`. Only set `release.name` when the template actually reads `.Release.Name`.

### Scope, Precedence, and Targeting

- Value precedence: chart `values.yaml` < suite `values` < suite `set` < test `values` < test `set`.
- Template scope precedence: suite `templates` narrowed by test `template` / `templates`, then by assertion-level `template`.
- Document targeting precedence: assertion `documentSelector` / `documentIndex` overrides the test-level selector or index.
- Use `documentSelector` for multi-document templates instead of a brittle numeric `documentIndex`.
- `hasDocuments` ignores selectors by default; set `filterAware: true` to count only selector/index-filtered documents.
- `documentSelector` fields: `path` (required), `value` (optional - omit it to filter on path existence alone), `matchMany` (allow more than one match), `skipEmptyTemplates` (tolerate templates that rendered nothing).
- A selector that matches in some of the suite's templates but not others is fine as is. A selector that matches **nothing at all** fails the assertion with `document not found`, even when the assertion is `hasDocuments: {count: 0, filterAware: true}`. That is the case `skipEmptyTemplates: true` fixes - reach for it when testing that a component renders nothing.

### Suite and Test Options

- `release`: for behavior that depends on `.Release` (`name`, `namespace`, `revision`, `upgrade`).
- `capabilities`: pin Kubernetes versions/APIs for branches guarded by `.Capabilities.*`.
- `chart`: override `.Chart.version` / `.Chart.appVersion` when output depends on them.
- `excludeTemplates`: narrow broad template globs to keep unrelated documents out of a suite.
- `skip`: only for temporary or unreleased behavior; prefer active assertions over skipped tests.

## Assertion Guidance

Grouped by what they inspect. Every assertion also takes `not`, `template`, `documentIndex`, and `documentSelector` at its root.

**Documents**

| Assertion | Purpose |
|---|---|
| `hasDocuments` | Number of documents rendered; takes `filterAware` |
| `containsDocument` | A document with this `kind` and `apiVersion` exists; takes optional `name` and `namespace` |
| `isKind` | Kind of the selected document |
| `isAPIVersion` | API version of the selected document |

**Values**

| Assertion | Purpose |
|---|---|
| `equal` / `notEqual` | Exact match at a path; takes `decodeBase64` |
| `exists` / `notExists` | Path is present or absent |
| `isEmpty` / `isNotEmpty` | Value is empty or not |
| `isNullOrEmpty` / `isNotNullOrEmpty` | Value is null/empty, or present with content |
| `isType` / `isNotType` | Value type: `string`, `int`, `bool`, ... |

**Arrays and maps**

| Assertion | Purpose |
|---|---|
| `contains` / `notContains` | Entry membership; takes `count` and `any` |
| `lengthEqual` / `notLengthEqual` | Length equals expected count; takes `paths` to check several at once |
| `isSubset` / `isNotSubset` | Expected object is contained in the rendered one |

**Comparisons**

| Assertion | Purpose |
|---|---|
| `greaterOrEqual` / `notGreaterOrEqual` | Numeric or string comparison |
| `lessOrEqual` / `notLessOrEqual` | Numeric or string comparison |

**Strings**

| Assertion | Purpose |
|---|---|
| `matchRegex` / `notMatchRegex` | Regex against a string value; takes `decodeBase64` |

**Rendering**

| Assertion | Purpose |
|---|---|
| `failedTemplate` | Render fails; match the message with `errorMessage` or `errorPattern` |
| `notFailedTemplate` | Render succeeds |

Two families the plugin offers that this repo deliberately does not use:

- `matchSnapshot` / `matchSnapshotRaw`. `make test` exposes no way to pass `-u`, by choice, so a snapshot can never be written or refreshed and `tests/__snapshot__/` stays empty. Do not write snapshot assertions.
- `equalRaw` / `notEqualRaw` / `matchRegexRaw` / `notMatchRegexRaw`. These exist to assert on `templates/NOTES.txt`, which we do not test.

Use `decodeBase64: true` on `equal` / `notEqual` / `matchRegex` when asserting on a Secret's `data`, which Helm renders base64-encoded. Values under `stringData` need no decoding.

Use antonym assertions (`notEqual`, `notContains`) instead of `not: true` unless `not: true` is clearer.

Prefer `equal`, `contains`, and specific negative assertions over broad `exists` checks. Specific assertions catch regressions.

Several templates guard values with `required`, e.g. `vcsGateway.domain` and `vcsGateway.gateway.gatewayClassName`. Cover those with `failedTemplate` and the exact message.

`contains` takes `count` for how many times the entry must appear, and `any: true` to match a subset of an element's fields rather than the whole element. Use `any` when you care that one key is set and not about everything else on that entry:

```yaml
      - contains:
          path: spec.template.spec.containers[0].env
          content:
            name: SPACELIFT_VERSION
          any: true
```

### Assertion Scoping Patterns

```yaml
  - it: targets one Deployment by name
    templates:
      - server-deployment.yaml
      - drain-deployment.yaml
    asserts:
      - equal:
          path: spec.replicas
          value: 1
        documentSelector:
          path: metadata.name
          value: spacelift-server
```

```yaml
  - it: counts only selected docs
    template: extra-manifests.yaml
    documentSelector:
      path: kind
      value: ConfigMap
      matchMany: true
    asserts:
      - hasDocuments:
          count: 2
          filterAware: true
```

### Multi-Template Safety

Most suites here list several templates. Set `template` on every assertion unless the test intentionally targets all of them.

Put `template` at the assertion root, not inside the assertion parameters.

Wrong:

```yaml
      - notContains:
          template: server-deployment.yaml
          path: spec.template.spec.containers
          content:
            name: cloud-sql-proxy
```

Correct:

```yaml
      - template: server-deployment.yaml
        notContains:
          path: spec.template.spec.containers
          content:
            name: cloud-sql-proxy
```

### Path and jsonPath Guidance

- Prefer precise paths over broad existence checks.
- When map keys contain dots or slashes, use jsonPath bracket syntax.
- Keep escaping consistent to avoid false negatives.

```yaml
  - equal:
      path: metadata.annotations["kubernetes.io/ingress.class"]
      value: nginx
```

### Conditional Rendering Tests

```yaml
  - it: renders nothing when disabled
    set:
      vcsGateway.enabled: false
    asserts:
      - hasDocuments:
          count: 0
```

### Testing with Release Values

```yaml
  - it: uses the release name
    release:
      name: example-release
    asserts:
      - equal:
          path: metadata.name
          value: example-release-credentials
```

## Test File Organization

`spacelift-self-hosted/templates/` is flat, so `tests/` is flat too. Group tests by behavior area, one file per area:

```text
spacelift-self-hosted/tests/
  cloud_sql_proxy_test.yaml
  extra_manifests_test.yaml
  mqtt_service_test.yaml
  pdb_validation_test.yaml
  service_accounts_test.yaml
  shared_workload_config_test.yaml
  vcs_gateway_test.yaml
```

Name files `<area>_test.yaml`. That is house convention rather than a plugin rule here: the plugin defaults to `tests/*_test.yaml`, but the Makefile overrides the glob to `tests/**/*.yaml`, so every `.yaml` under `tests/` runs as a suite and a stray file dropped in there gets executed.

Extend an existing file when the behavior fits its suite; add a new file for a new area.

## Writing Workflow

1. Read the template under test. Understand every conditional, value reference, helper call, and document it emits.
2. Read `templates/_helpers.tpl` for the helpers that template uses.
3. Read `values.yaml` for defaults, and `values.schema.json` for what `set` keys are allowed.
4. Work out whether the template emits zero, one, or many documents, and which selector is stable.
5. Write tests for default rendering, each significant conditional branch, `required` failures, selector behavior, and multi-template scoping.
6. Run the tests.
7. Fix failures by adjusting assertions to match the actual rendered output.
8. Repeat until the file passes.

## Running Tests

Tests run in Docker through the chart's own Makefile. Run the whole suite:

```bash
make -C spacelift-self-hosted test
```

Run one test file:

```bash
make -C spacelift-self-hosted test HELM_UNITTEST_FILE='tests/vcs_gateway_test.yaml'
```

`HELM_UNITTEST_FILE` is a glob relative to the chart directory; it defaults to `tests/**/*.yaml`.

`HELM_UNITTEST_FILE` is the only knob the Makefile exposes. The plugin's other flags - `-u`, `-q`, `-d`, `--skip-schema-validation` - are deliberately unreachable. Do not work around that by calling `docker run` by hand; if a test needs one of those flags, the test is wrong.

CI runs the same target from `.github/workflows/test-self-hosted-chart.yml` on any pull request touching `spacelift-self-hosted/**`.

### Version Pinning

The image is `helmunittest/helm-unittest:4.2.3-1.1.2` - Helm 4.2.3 with helm-unittest plugin 1.1.2 - set by `HELM_UNITTEST_TAG` in the chart Makefile.

Upstream docs on the `main` branch run ahead of 1.1.2. Check any feature you read about there against this build before using it:

```bash
docker run --rm helmunittest/helm-unittest:4.2.3-1.1.2 --help
```

`--parallel` and `--max-workers` are the current example: documented upstream, absent from this build.

## Rules

- Only create or edit `.yaml` files under `spacelift-self-hosted/tests/` when this skill is used to write tests.
- Do not modify templates, `values.yaml`, `values.schema.json`, or `Chart.yaml` as part of a test-writing task unless the user explicitly widens the scope.
- Never run destructive shell commands.
- Always run the relevant test command after writing tests.
- Reference templates by bare filename; the `templates/` prefix is legal upstream but unused here.
- Assert on `spacelift-*` names by default; `fullnameOverride` is `spacelift`.
- Set enable flags explicitly instead of relying on defaults when a template renders conditionally.
- If a test needs a value that `values.schema.json` rejects, stop and tell the user - the schema change is a chart change.
- Prefer `documentSelector` over a hardcoded `documentIndex` for templates that can reorder output.
- Use `hasDocuments.filterAware: true` when asserting counts under selector or index filtering.
- Use `template` / `templates` at test or assertion level to stop assertions bleeding across templates.
- For negative paths, assert absence with `notExists` or `notContains`.
- Do not write `matchSnapshot` assertions, and do not test `templates/NOTES.txt`. Neither is supported here.
- Do not add a `.yaml` file under `tests/` that is not a test suite. The glob runs everything it finds.

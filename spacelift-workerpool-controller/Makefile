SHELL := /bin/bash

CRDS_PATH ?= config/crd/bases
CRDS_OUT_DIR ?= charts/crds/templates
CHART_VERSION ?= v0.14.0

.PHONY: codegen-helm
codegen-helm: codegen-helm-crds codegen-helm-update-versions

.PHONY: codegen-helm-crds
codegen-helm-crds: 
	@echo "Generate helm CRDs..." >&2
	@test -d $(CRDS_PATH) || (echo "CRDS_PATH not found: $(CRDS_PATH)" >&2; exit 1)
	@rm -rf $(CRDS_OUT_DIR)
	@mkdir -p $(CRDS_OUT_DIR)
	$(call generate_crd,workers.spacelift.io_workers.yaml,worker-crd.yaml)
	$(call generate_crd,workers.spacelift.io_workerpools.yaml,workerpool-crd.yaml)

define generate_crd
	@cat $(CRDS_PATH)/$(1) \
		| awk ' \
			/^  annotations:/ { \
				print; \
				print "    {{- with .Values.annotations }}"; \
				print "    {{- toYaml . | nindent 4 }}"; \
				print "    {{- end }}"; \
				next; \
			} \
			{ print }' \
		> $(CRDS_OUT_DIR)/$(2)
endef

.PHONY: codegen-helm-update-versions
codegen-helm-update-versions: 
	@echo "Updating Chart.yaml files..." >&2
	@sed -i.bak 's/version: .*  # VERSION/version: $(CHART_VERSION)  # VERSION/' Chart.yaml
	@rm -f Chart.yaml.bak
	@sed -i.bak 's/version: .*  # VERSION/version: $(CHART_VERSION)  # VERSION/' charts/crds/Chart.yaml
	@rm -f charts/crds/Chart.yaml.bak

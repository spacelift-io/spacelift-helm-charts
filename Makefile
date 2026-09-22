MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

HELM_UNITTEST_TAG := 4.2.3-1.1.2

# Chart(s) to target (glob pattern, e.g. HELM_CHART=spacelift-self-hosted, HELM_CHART=spacelift-*)
HELM_CHART ?= spacelift-self-hosted
# Test file pattern within the chart (e.g. HELM_UNITTEST_FILE='tests/ingester/*_test.yaml')
HELM_UNITTEST_FILE  ?= tests/**/*.yaml

.PHONY: test
test:
	docker run --rm -v $(MAKEFILE_DIR):/apps helmunittest/helm-unittest:$(HELM_UNITTEST_TAG) --strict --file '$(HELM_UNITTEST_FILE)' $(HELM_CHART)

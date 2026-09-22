MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT_DIR := $(abspath $(MAKEFILE_DIR)/..)

HELM_UNITTEST_TAG := 4.2.3-1.1.2

# Test file pattern within the chart (e.g. HELM_UNITTEST_FILE='tests/ingester/*_test.yaml')
HELM_UNITTEST_FILE  ?= tests/**/*.yaml

.PHONY: test
test:
	docker run --rm --user "$$(id -u):$$(id -g)" -e HOME=/tmp -v $(REPO_ROOT_DIR):/apps helmunittest/helm-unittest:$(HELM_UNITTEST_TAG) --strict --file '$(HELM_UNITTEST_FILE)' spacelift-self-hosted

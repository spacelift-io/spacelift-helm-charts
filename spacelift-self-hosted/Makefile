MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

HELM_UNITTEST_TAG := 4.3.0-1.2.1

# Test file pattern within the chart (e.g. HELM_UNITTEST_FILE='tests/ingester/*_test.yaml')
HELM_UNITTEST_FILE  ?= tests/**/*.yaml

.PHONY: test
test:
	docker run --rm --user "$$(id -u):$$(id -g)" -e HOME=/tmp -v $(MAKEFILE_DIR):/apps helmunittest/helm-unittest:$(HELM_UNITTEST_TAG) --strict -u --file '$(HELM_UNITTEST_FILE)' .

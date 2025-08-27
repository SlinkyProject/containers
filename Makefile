##@ General

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= docker
REGISTRY ?= slinky.slurm.net

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Build Dependencies

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

## Tool Binaries
PANDOC ?= $(LOCALBIN)/pandoc-$(PANDOC_VERSION)

## Tool Versions
PANDOC_VERSION ?= 3.7.0.2

.PHONY: pandoc-bin
pandoc-bin: $(PANDOC) ## Download pandoc locally if necessary.
$(PANDOC): $(LOCALBIN)
	@if ! [ -f "$(PANDOC)" ]; then \
		if [ "$(shell go env GOOS)" != "darwin" ]; then \
			curl -sSLo $(PANDOC).tar.gz https://github.com/jgm/pandoc/releases/download/$(PANDOC_VERSION)/pandoc-$(PANDOC_VERSION)-$(shell go env GOOS)-$(shell go env GOARCH).tar.gz ;\
			tar xv --directory=$(LOCALBIN) --file=$(PANDOC).tar.gz pandoc-$(PANDOC_VERSION)/bin/pandoc --strip-components=2 ;\
		else \
			curl -sSLo $(PANDOC).zip https://github.com/jgm/pandoc/releases/download/$(PANDOC_VERSION)/pandoc-$(PANDOC_VERSION)-$(shell go env GOARCH)-macOS.zip ;\
			unzip -oqqjd $(LOCALBIN) $(PANDOC).zip ;\
		fi ;\
		mv $(LOCALBIN)/pandoc $(PANDOC) ;\
		rm -f $(PANDOC).tar.gz $(PANDOC).zip ;\
	fi

##@ Development
.PHONY: generate-docs
generate-docs: pandoc-bin
	$(PANDOC) --quiet README.md -o docs/index.rst
	cat ./docs/_static/toc.rst >> docs/index.rst
	printf '\n' >> docs/index.rst
	find docs -type f -name "*.md" -exec basename {} \; | awk '{print "    "$$1}' | env LC_ALL=C sort >> docs/index.rst
	sed -i -E '/<.\/docs\/[A-Za-z]*.md/s/.\/docs\///g' docs/index.rst
	sed -i -E '/<[A-Za-z]*.md>`/s/.md>/.html>/g' docs/index.rst

DOCS_IMAGE ?= $(REGISTRY)/sphinx

.PHONY: build-docs
build-docs: ## Build the container image used to develop the docs
	$(CONTAINER_TOOL) build -t $(DOCS_IMAGE) ./docs

.PHONY: run-docs
run-docs: build-docs ## Run the container image for docs development
	$(CONTAINER_TOOL) run --rm --network host -v ./docs:/docs:z $(DOCS_IMAGE) sphinx-autobuild --port 8000 /docs /build/html

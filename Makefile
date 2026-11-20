
DOCKER_REPO ?= szpaczyn
DOCKER_NAME := grafana-backup-tool
DOCKER_TAG ?= 1.4.2
PLATFORMS ?= linux/arm64

FULLTAG = $(DOCKER_REPO)/$(DOCKER_NAME):$(DOCKER_TAG)

DOCKERFILE=Dockerfile

all: build

build:
	docker build -t $(FULLTAG) -f $(DOCKERFILE) .

push: build
	docker push $(FULLTAG)

buildx_and_push:
	docker buildx build \
		--label=build-by=shpaq \
		--output type=image,name=$(DOCKER_REPO)/$(DOCKER_NAME),push=true \
	 	--platform $(PLATFORMS) \
		--tag $(FULLTAG) \
	 	--file $(DOCKERFILE) .

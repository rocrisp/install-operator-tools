IMAGE_BUILDER=podman
IMAGE_NAME=operator-install-audit
IMAGE_REPO=quay.io/john_mckenzie
IMAGE_VERSION=latest

# build: Build the container image.
.PHONY: build
build:
	$(IMAGE_BUILDER) build -t $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_VERSION) .

# push: Push the container image to the remote registry.
.PHONY: push
push:
	$(IMAGE_BUILDER) push $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_VERSION)

# run: Run the container image locally.
.PHONY: run
run:
	$(IMAGE_BUILDER) run -it $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_VERSION)

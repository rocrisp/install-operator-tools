IMAGE_BUILDER=podman
IMAGE_NAME=install-operators
IMAGE_REPO=quay.io/rocrisp
IMAGE_VERSION=latest
KUBE_CONFIG=~/.kube/config
TEMP_DIR=`pwd`/tmp

# build: Build the container image.
.PHONY: build
build:
	$(IMAGE_BUILDER) build -t $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_VERSION) .

# clean: Remove temporary artifacts.
.PHONY: clean
clean:
	rm -fr $(TEMP_DIR)

# push: Push the container image to the remote registry.
.PHONY: push
push:
	$(IMAGE_BUILDER) push $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_VERSION)

# run: Run the container image locally.
.PHONY: run
run:
	mkdir -p $(TEMP_DIR)
	$(IMAGE_BUILDER) run -it --rm \
		-v $(TEMP_DIR):/var/operator:Z \
		-v $(KUBE_CONFIG):/opt/operator/config:Z \
		-e KUBECONFIG=/opt/operator/config \
		$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_VERSION)

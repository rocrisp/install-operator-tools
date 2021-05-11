# install-operator-tools

Automate installing of operators on a cluster.

## Prerequisites

A Kubernetes/OpenShift cluster available.

## Usage

Use the provided manifest to deploy the tool as a Job in your cluster.

```bash
oc apply -f deploy/install.yaml
```

By default, a new namespace will be created called `operator-audit`. The Job will be created and run in this namespace.

## Development

There are several Make targets available to build and run the container image locally.

### Build/Push

Build the container image locally.

```bash
make build
```

Push the container image to a remote registry.

```bash
make push
```

### Run

Run the container image locally.

```bash
make run
```

### Advanced

Several variables can be used to customize the build and run targets.

#### IMAGE_BUILDER

The `IMAGE_BUILDER` variable by default is set to `podman`. Use this variable if an alternate image builder is desired.

```bash
make build IMAGE_BUILDER=docker
```

#### IMAGE_NAME

The `IMAGE_NAME` variable controls the name of the resulting container image.

```bash
make build IMAGE_NAME=my-image
```

#### IMAGE_REPO

The `IMAGE_REPO` variable controls the name of container registry/repository to use.

```bash
make build IMAGE_REPO=containers.pkg.github.com/johndoe
```

#### IMAGE_VERSION

The `IMAGE_VERSION` variable controls the tag that will be used for the container image.

```bash
make build IMAGE_VERSION=v1.0.0
```

#### KUBE_CONFIG

The `KUBE_CONFIG` variable by default is set to `~/.kube/config`. This variable can be used to refer to an alternate kubeconfig to be used when running the image locally.

```bash
make run KUBE_CONFIG=~/my-kube-config.yaml
```

#### TEMP_DIR

The `TEMP_DIR` variable by default is set to `'pwd'/tmp`. This variable can be used to change the directory that is used to cache the generated artifacts when running the image locally.

```bash
make run TEMP_DIR=`pwd`/my-dir
```

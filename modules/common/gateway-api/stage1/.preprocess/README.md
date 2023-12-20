# Pre-Processing

Since TF doesn't play well with multi-doc yaml files, we split original manifests into individual docs as a pre-processing step.

If we need to update the manifests because there has been a change upstream, the process to follow is the following:

1. download the original yaml files from the official source into the current folder

2. use the `yq` tool split each file into sub files

Run the following command from the `/manifests` folder

```sh
yq -s '.metadata.name' --no-doc 'del(.status)' < ../.preprocess/standard.yaml
yq -s '.metadata.name' --no-doc 'del(.status)' < ../.preprocess/experimental.yaml
yq -s '.metadata.name' --no-doc 'del(.status)' < ../.preprocess/kong.yaml
```

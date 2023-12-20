# Stage 1

Stage 1 of the bootstrap procedure is responsible for setting up static resources in the Kubernetes cluster. By static we refer to self-contained resources that are common to any implementation regardless of the specific use-case.

## Dependencies

- Stage 0 completed
- Terraform CLI
- Kubernetes configuration

## Procedure

### Define your Terraform backend

Add a `backend.tf` file in the stage1 directory and include your particular backend configuration. For example:

```tf
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
```

### Initialize Terraform

Initialize the stage1 module by running the `init` command from stage1 directory:

```sh
terraform init
```
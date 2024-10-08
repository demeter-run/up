# Stage 2

Stage 2 of the bootstrap procedure is responsible for setting up active workload resources for shared services in the Kubernetes cluster. These resources are common to any implementation regardless of the specific use-case, such as: monitoring, logging, secret management and Demeter's daemon.

## Dependencies

- Stage 1 completed
- Terraform CLI
- Kubernetes configuration

## Procedure

### Define your Terraform backend

Add a `backend.tf` file in the stage1 directory and include your particular backend configuration. If you run `bin/bootstrap-cloud` the `backend.tf` should be automatically generated. For example AWS S3 backend configuration:

```tf
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
```

> [!TIP]
> You can skip this step and Terraform by default will use a local state backend which stores the data in the current folder. This is an easy and good approach for local development or testing, but it doesn't scale easily for production environments.

### Initialize Terraform

Initialize the stage2 module by running the `init` command from stage2 directory:

```sh
terraform init
```

Make sure that terraform command completed successfully and there're no error reports in the terminal output.

### Define Variable Values

Specify the correct values for the required stage2 variables by modifying the `env.auto.tfvars` file.

The following variables are required:

- `k8s_context`: The name of the k8s context as defined in the kube config file. This should match the context created during the stage0 setup of your k8s cluster.

> [!TIP]
> There are other variables available that you can use to tailor the installation but they have reasonable defaults. Check the `variables.tf` file for the definition of each. If you want to override the default value, add the corresponding line to `env.auto.tfvars` specifying the adjusted value.

### Apply Terraform

Apply the required changes for stage2 by running the `apply` command from stage2 directory.

```sh
terraform apply
```

The output will show you the planned changes before applying them. Answer 'yes' in the confirmation step to continue with the process.

The execution of the command might take a while depending on the specific cluster. Make sure that terraform command completed successfully and there're no error reports in the terminal output.

## Next Steps

You're done with stage 2. You can continue with [Stage 3](../stage3/README.md)

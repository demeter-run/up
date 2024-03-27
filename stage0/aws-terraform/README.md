# Stage 0

Stage 0 of the bootstrap procedure is responsible for setting up a Kubernetes
cluster compatible with Demeter.

The specific Compute infrastructure and Kubernetes control-plane are
out-of-scope for Demeter. We provide instructions for different common
scenarios, but feel free to configure it your own way, the only strict
requirement is following a specific convention for worker node taint
configuration.

## Stage 0 - AWS EKS version

Instructions on how to execute the stage 0 bootstrap procedure using AWS and
EKS (Elastic Kubernetes Service).

## Dependencies

- Terraform
- AWS account 

## Customize your settings

This folder contains Terraform code for creating a cluster in AWS with managed
node groups. Configuration is done in the top-level `config.yaml`.

You need to edit the yaml file and customize whatever you consider relevant.
For example:

The name and region of your cluster:

```yaml
cluster_name: <name of the cluster>
region: <aws region>
```

The availability zones:

```yaml
azs: [<aws az 1>, <aws az 2>]
```

The CIDR for your VPC:

```yaml
vpc_cidr: <vpc cidr>
```

## Create the cluster

Creating the cluster uses Terraform.

### Define your Terraform backend

Add a `backend.tf` file in the stage1 directory and include your particular
backend configuration. For example:

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
> You can skip this step and Terraform by default will use a local state
> backend which stores the data in the current folder. This is an easy and
> good approach for local development or testing, but it doesn't scale easily
> for production environments.

### Initialize Terraform

Initialize the stage 1 module by running the `init` command from stage1
directory:

```sh
terraform init
```

Make sure that terraform command completed successfully and there are no error
reports in the terminal output.

Run the following command from your terminal to execute a dry-run of the
provisioning to make sure that everything works before affecting your
infrastructure:

```bash
terraform plan
```

If everything worked correctly and you're happy with the output, run the apply
command to apply the changes:

```bash
terraform apply
```

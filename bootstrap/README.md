# Bootstrap

Bootstrap is optional and will configure a cloud provider for storing the Terraform state in the cloud. This allows
teams to collaborate on the same Kubernetes cluster.

This process will read any configuration from the top-level `config.yaml` file. This is how you override attributes
such as the cloud provider region to use. Executing bootstrap will also configure the later stages with the correct
inputs as created during the bootstrap.

## Usage

Bootstrap has two distinct scripts. The `bin/bootstrap-cloud` script is used to start from scratch and create an
initial deployment in the cloud. It will start with the bootstrap terraform which configures the requisites for a
terraform remote backend. After that, it will migrate its own state to the created cloud storage bucket. Next, it
will execute the correct chose stage0 for the configured cloud provider, using terraform, for example:
`stage0/aws-terraform`.

**WARNING**: The above changes are applied without confirmation. Only execute bootstrap once!

Since the `bin/bootstrap-cloud` script should only be executed one time, when onboarding additional team members,
you will need to provide them with a configured `config.yaml` for them to use with the `bin/setup` script. The
`bin/setup` script will read a `config.yaml` and populate the `backend.tf` and `env.auto.tfvars` files in each
stage.

The `config.yaml` for sharing a cluster must contain at least the following data:

```yaml
cloud_provider: <provider>
cloudflared_token: <token>
terraform_state_bucket: <bucket>
terraform_state_region: <region>
```

Currently, this supports AWS, but we intend on supporting additional providers in the
future.

## Next Steps

You're done with bootstrap. You can continue with [Stage 1](../stage1/README.md)

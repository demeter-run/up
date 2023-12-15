# Stage 0 - AWS EKS version

Instructions on how to execute the stage 0 bootstrap procedure using AWS and EKS (Elastic Kubernetes Service).

## Dependencies

- eksctl: https://eksctl.io/
- AWS account 

## Customize your settings

The `cluster.yaml` file in this folder contains a template of a configuration file to setup a new cluster using `eksctl`.

You need to edit the yaml file and customize whatever you consider relevant. For example:

The name and region of your cluster:

```yaml
metadata:
  name: <name of the cluster>
  region: <aws region>
```

The availability zones:

```yaml
availabilityZones: [<aws az 1>, <aws az 2>]
```

The CIDR for your VPC:

```yaml
vpc:
  cidr: <vpc cidr>
```

## Create the cluster

Run the following command from your terminal to execute a dry-run of the provisioning to make sure that everything works before affecting your infrastructure:

```bash
eksctl create cluster -f cluster.yaml --dry-run
```

If everything worked correctly and you're happy with the output, remove the dry-run flag and execute the command again:

```bash
eksctl create cluster -f cluster.yaml
```


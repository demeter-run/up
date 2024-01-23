locals {
  default_vars = yamldecode(file("../../common/defaults.yaml"))
  cluster_vars = yamldecode(file("../aws-eksctl/cluster.yaml"))
  config_vars  = try(yamldecode(file("../../config.yaml")), {})

  name = try(
    local.config_vars.metadata.name,
    local.cluster_vars.metadata.name,
    local.default_vars.cluster_name,
  )
  region = try(
    local.config_vars.metadata.region,
    local.cluster_vars.metadata.region,
    local.default_vars.region,
  )
  azs = try(
    local.config_vars.availabilityZones,
    local.cluster_vars.availabilityZones,
    split(",", local.default_vars.azs),
  )
  vpc_vars = try(
    local.config_vars.vpc,
    local.cluster_vars.vpc,
    { "cidr" : local.default_vars.vpc_cidr },
  )
  node_vars = try(
    local.config_vars.managedNodeGroups,
    local.cluster_vars.managedNodeGroups,
    local.default_vars.managed_node_groups,
  )

  cluster_version = "1.27"

  tags = {
    Name = local.name
  }
}

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.aws_cluster_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_cluster_eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.aws_cluster_eks.cluster_name]
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

module "aws_cluster_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_vars.cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_vars.cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_vars.cidr, 8, k + 4)]

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "public"                 = "true"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "private"                         = "true"
  }

  tags = local.tags
}

data "aws_subnets" "filtered" {
  for_each = toset(local.azs)

  depends_on = [module.aws_cluster_vpc]

  filter {
    name   = "vpc-id"
    values = [module.aws_cluster_vpc.vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = ["${each.value}"]
  }

  filter {
    name   = "tag:private"
    values = ["true"]
  }
}

module "aws_cluster_vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    main = {
      provider_arn               = module.aws_cluster_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

module "aws_cluster_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        tolerations : [
          {
            key : "demeter.run/compute-arch",
            operator : "Equal",
            value : "arm64",
            effect : "NoSchedule"
          },
          {
            key : "demeter.run/compute-arch",
            operator : "Equal",
            value : "x86",
            effect : "NoSchedule"
          },
          {
            key : "demeter.run/compute-profile",
            operator : "Equal",
            value : "general-purpose",
            effect : "NoSchedule"
          },
          {
            key : "demeter.run/availability-sla",
            operator : "Equal",
            value : "best-effort",
            effect : "NoSchedule"
          },
        ]
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.aws_cluster_vpc.vpc_id
  subnet_ids               = module.aws_cluster_vpc.private_subnets
  control_plane_subnet_ids = module.aws_cluster_vpc.public_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["m6a.2xlarge", "m6i.2xlarge", "t3.2xlarge", "m5.2xlarge", "m5a.2xlarge"]

    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = { for n in local.node_vars :
    n.name => {
      name           = n.name
      labels         = try(n.labels, {})
      ami_type       = n.labels["demeter.run/compute-arch"] == "arm64" ? "AL2_ARM_64" : "AL2_x86_64"
      instance_types = try(tolist(n.instanceType), n.instanceTypes, null)
      min_size       = try(n.minSize, 0)
      max_size       = try(n.maxSize, 1)
      desired_size   = try(n.desiredCapacity, 0)

      taints = [
        for t in coalesce(n.taints, []) : {
          key    = "${t.key}"
          value  = "${t.value}"
          effect = "${local.taint_effects_reverse[t.effect]}"
        }
      ]

      subnet_ids = flatten([
        for s in coalesce(n.availabilityZones, []) :
        data.aws_subnets.filtered[replace(s, "/^[a-z]+-[a-z]+-[0-9]/", "${local.region}")].ids
      ])
      capacity_type = try(n.capacityType, null)
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AdministratorAccess"
      username = "admin"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    data.aws_caller_identity.current.account_id,
  ]

  tags = local.tags
}

locals {
  taint_effects_reverse = {
    NoSchedule       = "NO_SCHEDULE"
    NoExecute        = "NO_EXECUTE"
    PreferNoSchedule = "PREFER_NO_SCHEDULE"
  }
}

################################################################################
# Tags for the ASG to support cluster-autoscaler scale up from 0
################################################################################

locals {

  # We need to lookup K8s taint effect from the AWS API value
  taint_effects = {
    NO_SCHEDULE        = "NoSchedule"
    NO_EXECUTE         = "NoExecute"
    PREFER_NO_SCHEDULE = "PreferNoSchedule"
  }

  cluster_autoscaler_label_tags = merge([
    for name, group in module.aws_cluster_eks.eks_managed_node_groups : {
      for label_name, label_value in coalesce(group.node_group_labels, {}) : "${name}|label|${label_name}" => {
        autoscaling_group = group.node_group_autoscaling_group_names[0],
        key               = "k8s.io/cluster-autoscaler/node-template/label/${label_name}",
        value             = label_value,
      }
    }
  ]...)

  cluster_autoscaler_taint_tags = merge([
    for name, group in module.aws_cluster_eks.eks_managed_node_groups : {
      for taint in coalesce(group.node_group_taints, []) : "${name}|taint|${taint.key}" => {
        autoscaling_group = group.node_group_autoscaling_group_names[0],
        key               = "k8s.io/cluster-autoscaler/node-template/taint/${taint.key}"
        value             = "${taint.value}:${local.taint_effects[taint.effect]}"
      }
    }
  ]...)

  cluster_autoscaler_asg_tags = merge(local.cluster_autoscaler_label_tags, local.cluster_autoscaler_taint_tags)
}

resource "aws_autoscaling_group_tag" "cluster_autoscaler_label_tags" {
  for_each = local.cluster_autoscaler_asg_tags

  autoscaling_group_name = each.value.autoscaling_group

  tag {
    key   = each.value.key
    value = each.value.value

    propagate_at_launch = false
  }
}

terraform {
  required_version = ">= 1.0.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

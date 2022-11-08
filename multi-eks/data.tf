data "aws_region" "current" {}

data "aws_availability_zones" "azs" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "this" {
  for_each = { for project in local.projects : "${project.name}" => project }

  name = aws_eks_cluster.this[each.value.name].id
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  projects = [
    {
      name     = "mng"
      vpc_cidr = "10.10.0.0/16"
    },
    {
      name     = "api"
      vpc_cidr = "10.20.0.0/16"
    }
  ]
  subnets = flatten([
    for project in local.projects : [
      for idx, az in data.aws_availability_zones.azs.names : {
        project = project.name
        az      = az
        index   = idx
      }
    ]
  ])
}
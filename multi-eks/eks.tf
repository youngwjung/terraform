resource "aws_iam_role" "eks_service_role" {
  name = "eks-cluster-service-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_service_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_service_role.name
}

resource "aws_eks_cluster" "this" {
  for_each = { for project in local.projects : "${project.name}" => project }
  
  name     = each.value.name
  role_arn = aws_iam_role.eks_service_role.arn
  version  = "1.23"

  vpc_config {
    subnet_ids = [
      for subnet in aws_subnet.public: subnet.id if subnet.vpc_id == aws_vpc.this[each.value.name].id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_service_role
  ]
}

resource "aws_iam_role" "eks_node" {
  name = "eks-nodegroup-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_node-AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_launch_template" "eks_nodegroup" {
  name = "eks-nodegroup"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp3"
      volume_size = 20
    }
  }
}

resource "aws_eks_node_group" "this" {
  for_each = { for project in local.projects : "${project.name}" => project }
  
  cluster_name    = aws_eks_cluster.this[each.value.name].id
  node_group_name = "nodegroup"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids = [
    for subnet in aws_subnet.public: subnet.id if subnet.vpc_id == aws_vpc.this[each.value.name].id
  ]
  instance_types  = ["t3.medium"]

  launch_template {
    id      = aws_launch_template.eks_nodegroup.id
    version = aws_launch_template.eks_nodegroup.latest_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_node-AdministratorAccess,
    aws_iam_role_policy_attachment.eks_node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node-AmazonEC2ContainerRegistryReadOnly
  ]
}
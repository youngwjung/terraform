provider "aws" {
  region = "ap-northeast-2"
}

provider "kubernetes" {
  alias = "mng"
  host                   = aws_eks_cluster.this["mng"].endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this["mng"].certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this["mng"].token
}

provider "kubernetes" {
  alias = "api"
  host                   = aws_eks_cluster.this["api"].endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this["api"].certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this["api"].token
}

provider "helm" {
  alias = "mng"
  kubernetes {
    host                   = aws_eks_cluster.this["mng"].endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this["mng"].certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this["mng"].token
  }
  debug = true
}

provider "helm" {
  alias = "api"
  kubernetes {
    host                   = aws_eks_cluster.this["api"].endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this["api"].certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this["api"].token
  }
  debug = true
}

provider "kubectl" {
  alias                  = "mng"
  host                   = aws_eks_cluster.this["mng"].endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this["mng"].certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this["mng"].token
}

provider "kubectl" {
  alias                  = "api"
  host                   = data.aws_eks_cluster.this["api"].endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this["api"].certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this["api"].token
}
resource "helm_release" "mng_metric_server" {
  provider   = helm.mng
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"
  
  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "api_metric_server" {
  provider   = helm.api
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"
  
  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "mng_cluster_autoscaler" {
  provider   = helm.mng
  
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  timeout    = 900

  dynamic "set" {
    for_each = {
      "fullnameOverride"           = "cluster-autoscaler"
      "awsRegion"                  = data.aws_region.current.name
      "autoDiscovery.clusterName"  = "mng"
      "service.create"             = false
    }
    content {
      name  = set.key
      value = set.value
    }
  }
  
  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "api_cluster_autoscaler" {
  provider   = helm.api
  
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  timeout    = 900

  dynamic "set" {
    for_each = {
      "fullnameOverride"           = "cluster-autoscaler"
      "awsRegion"                  = data.aws_region.current.name
      "autoDiscovery.clusterName"  = "api"
      "service.create"             = false
    }
    content {
      name  = set.key
      value = set.value
    }
  }
  
  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "mng_external_dns" {
  provider   = helm.mng
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = "kube-system"
  
  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "api_external_dns" {
  provider   = helm.api
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = "kube-system"
  
  depends_on = [aws_eks_node_group.this]
}
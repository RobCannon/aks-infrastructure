# https://hub.helm.sh/charts/stable/nginx-ingress
# https://www.terraform.io/docs/providers/helm/release.html

resource "helm_release" "nginx-ingress" {
  name      = "nginx-ingress"
  chart     = "stable/nginx-ingress"
  version   = "1.4.0"
  namespace = "kube-system"

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.electionID"
    value = "ingress-controller-leader"
  }

  set {
    name  = "controller.ingressClass"
    value = "nginx"
  }

  set {
    name  = "controller.podLabels.app"
    value = "nginx-ingress"
  }

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "defaultBackend.podAnnotations.app"
    value = "nginx-ingress"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }
}

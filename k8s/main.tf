resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "oci://quay.io/jetstack/charts"
  chart            = "cert-manager"
  version          = "v1.18.2"
  namespace        = "cert-manager"
  create_namespace = true
  set = [{
    name  = "crds.enabled"
    value = "true"
  }]
}

locals {
  letsencrypt = {
    staging = {
      server = "https://acme-staging-v02.api.letsencrypt.org/directory"
      email = var.letsencrypt_issuer_email
    }
    prod = {
      server = "https://acme-v02.api.letsencrypt.org/directory"
      email = var.letsencrypt_issuer_email
    }
  }
}

resource "kubernetes_manifest" "letsencrypt_clusterissuer" {
  depends_on = [ helm_release.cert_manager ]

  for_each = local.letsencrypt

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-${each.key}"
    }
    spec = {
      acme = {
        email = lookup(each.value, "email")
        privateKeySecretRef = {
          name = "letsencrypt-${each.key}"
        }
        server = lookup(each.value, "server")
        solvers = [{
          http01 = {
            ingress = {
              class = "traefik"
            }
          }
        }]
      }
    }
  }
}


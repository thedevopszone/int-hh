# Nexus


Links: https://registry.terraform.io/providers/datadrivers/nexus/latest/docs



```
provider "nexus" {
  insecure = true
  password = "admin123"
  url      = "https://127.0.0.1:8080"
  username = "admin"
}
```


docker_proxy
```
resource "nexus_repository_docker_proxy" "dockerhub" {
  name   = "dockerhub"
  online = true

  docker {
    force_basic_auth = false
    v1_enabled       = false
    subdomain        = "docker" # Pro-only
  }

  docker_proxy {
    index_type = "HUB"
  }

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
  }

  proxy {
    remote_url       = "https://registry-1.docker.io"
    content_max_age  = 1440
    metadata_max_age = 1440
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    blocked    = false
    auto_block = true
  }
}
```


docker_hosted
```
resource "nexus_repository_docker_hosted" "example" {
  name   = "example"
  online = true

  docker {
    force_basic_auth = false
    v1_enabled       = false
    subdomain        = "docker" # Pro-only
  }

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }
}
```


helm_hosted
```
resource "nexus_repository_helm_hosted" "internal" {
  name   = "helm-internal"
  online = true

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = false
    write_policy                   = "ALLOW"
  }
}
```



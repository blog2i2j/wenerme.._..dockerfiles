variable "IMAGE_NAME" { default = "postgres" }
variable "PG_MAJOR" { default = "18" }
variable "MYSQL_FDW_VERSION" { default = "REL-2_9_3" }
variable "PGVECTOR_VERSION" { default = "0.8.2" }
variable "PG_CRON_VERSION" { default = "1.6.7" }
variable "PG_TLE_VERSION" { default = "1.5.2" }

group "default" {
  targets = ["postgres"]
}

target "base" {
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64", "linux/arm64"]
  pull       = true
  args = {
    PG_MAJOR          = PG_MAJOR
    MYSQL_FDW_VERSION = MYSQL_FDW_VERSION
    PGVECTOR_VERSION  = PGVECTOR_VERSION
    PG_CRON_VERSION   = PG_CRON_VERSION
    PG_TLE_VERSION    = PG_TLE_VERSION
  }
}

target "postgres" {
  inherits = ["base"]
  context  = "postgres"
  tags     = tags("latest")
}

function "tags" {
  params = [name]
  result = [
    "docker.io/wener/${IMAGE_NAME}:${name}",
    "quay.io/wener/${IMAGE_NAME}:${name}",

    "docker.io/wener/${IMAGE_NAME}:${notequal("latest", name) ? "${name}-" : ""}${PG_MAJOR}",
    "quay.io/wener/${IMAGE_NAME}:${notequal("latest", name) ? "${name}-" : ""}${PG_MAJOR}",
  ]
}

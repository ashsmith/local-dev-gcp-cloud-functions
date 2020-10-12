locals {
  region = "europe-west1"
}

provider "google-beta" {
  project = var.project
  region  = local.region
}

provider "google" {
  project = var.project
  region  = local.region
}

terraform {
  required_version = "0.13.4"
}

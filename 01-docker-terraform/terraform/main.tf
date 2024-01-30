# Define Terraform
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

# Define Providers
provider "google" {
  credentials = file(var.credentials)
  project     = var.my_project
  region      = "us-central1"
}

# Define a Resource
resource "google_storage_bucket" "demo_bucket" {
  name          = var.my_project
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }

}

resource "google_bigquery_dataset" "terraform_bq_resource_name" {
  dataset_id = "my_GCP_dataset"
}
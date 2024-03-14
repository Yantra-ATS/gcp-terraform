

# main.tf

terraform {
  required_version = ">= 1.3"

  required_providers {
    google = ">= 3.3"
  }
}
provider "google" {
  project = "webmobilez1408"
  region  = "us-east-1"
}

# Deploy image to Cloud Run
resource "google_cloud_run_service" "webmobilez2" {
  name     = "webmobilez2"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}
# Create public access
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
# Enable public access on Cloud Run service
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.webmobilez2.location
  project     = google_cloud_run_service.webmobilez2.project
  service     = google_cloud_run_service.webmobilez2.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
# Return service URL
output "url" {
  value = "${google_cloud_run_service.webmobilez2.status[0].url}"
}
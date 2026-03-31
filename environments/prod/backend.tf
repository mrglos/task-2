terraform {
  backend "gcs" {
    prefix = "terraform/prod/state"
  }
}

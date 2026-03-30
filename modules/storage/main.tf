resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.region
  project       = var.project_id
  
  # Allow Terraform to delete the bucket even if it contains objects
  force_destroy = true 

  # Recommended for security - prevents ACLs and enforces uniform access control at the bucket level
  uniform_bucket_level_access = true

  # Enabling versioning allows you to recover from accidental deletions or overwrites
  # by keeping previous versions of objects in the bucket.
  versioning {
    enabled = true
  }
}

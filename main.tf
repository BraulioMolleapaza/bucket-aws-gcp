# Configuración de providers
provider "aws" {
  region = "us-east-1"
}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
}

# Bucket S3 en AWS
resource "aws_s3_bucket" "source_bucket" {
  bucket = var.aws_bucket_name

  tags = {
    Environment = var.environment
    Project     = "bucket-sync"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "source_bucket_versioning" {
  bucket = aws_s3_bucket.source_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket GCS en GCP
resource "google_storage_bucket" "destination_bucket" {
  name     = var.gcs_bucket_name
  location = "US"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    project     = "bucket-sync"
    managed_by  = "terraform"
  }

  encryption {
    default_kms_key_name = "projects/${var.project}/locations/global/keyRings/${var.keyring}/cryptoKeys/${var.key}"
  }

  # Added logging bucket resource
  logging {
    log_bucket = google_storage_bucket.logging.name
  }
}

resource "google_storage_bucket" "logging" {
  name     = "${var.gcs_bucket_name}-logs"
  location = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}


resource "google_storage_bucket" "transfer_logs" {
  name     = "${var.gcs_bucket_name}-transfer-logs"
  location = "US"
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Service Account GCP
resource "google_service_account" "sync_service_account" {
  account_id   = "bucket-sync-sa"
  display_name = "Bucket Sync Service Account"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.sync_service_account.email}"
}

resource "google_storage_transfer_job" "gcs_to_s3" {
  description = "Transferencia programada de GCS a S3"
  project     = var.gcp_project_id

  transfer_spec {
    aws_s3_data_source {
      bucket_name = aws_s3_bucket.source_bucket.id
      aws_access_key {
        access_key_id     = var.aws_access_key
        secret_access_key = var.aws_secret_key
      }
    }
    gcs_data_sink {
      bucket_name = google_storage_bucket.destination_bucket.name
    }
    transfer_options {
      overwrite_objects_already_existing_in_sink = true
    }
  }

  schedule {
    schedule_start_date {
      year  = 2025
      month = 1
      day   = 1
    }
    start_time_of_day {
      hours   = 12  # Ejecutar 12 horas después del otro job
      minutes = 0
      seconds = 0
      nanos   = 0
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source_bucket.id

  topic {
    topic_arn = aws_sns_topic.bucket_updates.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_sns_topic" "bucket_updates" {
  name = "s3-bucket-updates"
}
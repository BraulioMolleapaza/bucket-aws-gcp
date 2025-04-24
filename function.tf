resource "google_storage_bucket" "function_bucket" {
  name     = "${var.gcs_bucket_name}-functions"
  location = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function-${timestamp()}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "function/function.zip"
}

resource "google_cloudfunctions_function" "sync_function" {
  name        = "bucket-sync-function"
  runtime     = "python39"
  
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.bucket_updates.name
  }
}
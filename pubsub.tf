resource "google_pubsub_topic" "bucket_updates" {
  name = "bucket-updates"
}

resource "google_pubsub_subscription" "bucket_updates" {
  name  = "bucket-updates-sub"
  topic = google_pubsub_topic.bucket_updates.name

  ack_deadline_seconds = 20
}
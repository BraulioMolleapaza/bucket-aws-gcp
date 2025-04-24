resource "google_monitoring_alert_policy" "sync_errors" {
  display_name = "Sync Errors Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "High error rate"
    condition_threshold {
      filter     = "metric.type=\"custom.googleapis.com/sync/errors\""
      duration   = "300s"
      comparison = "COMPARISON_GT"
      threshold_value = 5
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
}
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification Channel"
  type         = "email"
  
  labels = {
    email_address = var.notification_email
  }
}

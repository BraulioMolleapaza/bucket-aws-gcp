from google.cloud import monitoring_v3
from google.cloud.monitoring_v3 import MetricServiceClient

class SyncMetrics:
    def __init__(self):
        self.client = MetricServiceClient()
        self.project_path = self.client.project_path(project_id)

    def record_sync_latency(self, latency_seconds):
        metric_path = self.client.metric_descriptor_path(
            project_id,
            'custom.googleapis.com/sync/latency'
        )
        
        self.client.create_time_series(self.project_path, [{
            'metric': {'type': metric_path},
            'points': [{
                'value': {'double_value': latency_seconds}
            }]
        }])
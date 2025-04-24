
variable "notification_email" {
  description = "Email para notificaciones de alertas"
  type        = string
}

variable "max_retry_attempts" {
  description = "Número máximo de reintentos para sincronización"
  type        = number
  default     = 3
}

variable "gcp_project_id" {
  description = "ID del proyecto en GCP"
  type        = string
}

variable "aws_bucket_name" {
  description = "Nombre del bucket en AWS S3"
  type        = string
}

variable "gcs_bucket_name" {
  description = "Nombre del bucket en Google Cloud Storage"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "production"
}

variable "aws_access_key" {
  description = "AWS Access Key para transferencia"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key para transferencia"
  type        = string
}

variable "project" {
  description = "ID del proyecto GCP para KMS"
  type        = string
}

variable "keyring" {
  description = "Nombre del keyring KMS"
  type        = string
}

variable "key" {
  description = "Nombre de la llave KMS"
  type        = string
}

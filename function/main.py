from google.cloud import storage
import boto3
import json
import hashlib
from tenacity import retry, stop_after_attempt, wait_exponential

class SyncError(Exception):
    pass

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
def sync_object(source_bucket, object_key, dest_bucket):
    try:
        # Obtener objeto de S3
        s3_object = source_bucket.Object(object_key).get()
        
        # Calcular MD5
        md5_hash = hashlib.md5(s3_object['Body'].read()).hexdigest()
        
        # Subir a GCS con verificación
        blob = dest_bucket.blob(object_key)
        blob.upload_from_file(
            s3_object['Body'],
            md5_hash=md5_hash,
            retry=True
        )
        
        return True
    except Exception as e:
        raise SyncError(f"Error sincronizando {object_key}: {str(e)}")
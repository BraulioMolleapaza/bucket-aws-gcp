def verify_object_integrity(source_object, dest_blob):
    """Verifica la integridad del objeto sincronizado."""
    source_md5 = source_object.get()['ETag'].strip('"')
    dest_md5 = dest_blob.md5_hash
    
    if source_md5 != dest_md5:
        raise IntegrityError(
            f"MD5 mismatch for {source_object.key}: "
            f"source={source_md5}, dest={dest_md5}"
        )
    return True
import os
import boto3
import botocore.exceptions

from dotenv import load_dotenv

load_dotenv()

def save_data_from_request(file_path: str, bucket_name: str):
    client = boto3.resource('s3')

    try:
        client.Bucket(bucket_name).upload_file(file_path, "baofd-predicted-data/test_file_result.csv")
    except botocore.exceptions.ClientError as err:
        print(f"Failed to upload file {file_path} in bucket. Error: {err}")
        return False
    
    return True
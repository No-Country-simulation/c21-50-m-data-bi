import os
import boto3
import botocore.exceptions
import pandas as pd

from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

def create_s3_conn():
    session = boto3.Session(
        aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
        region_name=os.getenv('AWS_REGION')
    )

    return session.client('s3')

def upload_file_s3_ingestion(s3_client, file_path: str, bucket_name: str, object_in_bucket: str, filename: str) -> bool:
    s3 = s3_client

    try:
        s3.upload_file(file_path, bucket_name, f"{object_in_bucket}/{filename}")
    except botocore.exceptions.ClientError as err:
        print(f"Failed to upload file {filename} in bucket. Error: {err}")
        return False
    
    return True

def __generate_tmp_file_for_s3(df: pd.DataFrame, filename: str, filepath: str) -> str:
    tmp_directory = filepath
    os.makedirs(tmp_directory, exist_ok=True)
    tmp_filepath = os.path.join(tmp_directory, filename)

    df.to_csv(tmp_filepath, index=False)

    return tmp_filepath

def save_file_from_request(original_df: pd.DataFrame, predicted_df: pd.DataFrame) -> tuple[str | None, dict | None]:
    try:
        current_datetime = datetime.now()
        format_current_datetime = current_datetime.strftime("%Y%m%d_%H%M%S")
        tmp_dir = "/tmp/data_original_predicted"

        # Generate temporal file from original DataFrame
        filename_original_dataset = f"org-{format_current_datetime}-original_dataset.csv"
        original_dataset_tmp_path = __generate_tmp_file_for_s3(original_df, filename_original_dataset, tmp_dir)

        # Generate temporal file from predicted DataFrame
        filename_result_prediction = f"res-{format_current_datetime}-result_prediction.csv"
        dataset_prediction_tmp_path = __generate_tmp_file_for_s3(predicted_df, filename_result_prediction, tmp_dir)
        
        # Upload temporal files into S3
        bucket_data_ingestion = os.getenv('BUCKET_NAME')
        session_client = create_s3_conn()

        s3_original_dataset_upload = upload_file_s3_ingestion(session_client, 
                                                                original_dataset_tmp_path, 
                                                                bucket_data_ingestion,
                                                                'baofd-data-registered',
                                                                filename_original_dataset)
        
        s3_dataset_prediction_upload = upload_file_s3_ingestion(session_client, 
                                                                dataset_prediction_tmp_path, 
                                                                bucket_data_ingestion,
                                                                'baofd-data-predicted',
                                                                filename_result_prediction)

        if not s3_original_dataset_upload or not s3_dataset_prediction_upload:
            return None, {"error": "Error while uploading dataset file to S3"}
    except Exception as err:
        return None, {"error": str(err)}
    
    return filename_result_prediction, None

def download_result_from_prediction(filename: str) -> tuple[str | None, dict | None]:
    session_client = create_s3_conn()
    bucket_data_ingestion = os.getenv('BUCKET_NAME')

    try:
        s3_download_url = session_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': bucket_data_ingestion, 'Key': 'baofd-data-predicted/' + filename},
            ExpiresIn=600
        )

        return s3_download_url, None
    except Exception as err:
        return None, {"error": str(err)}
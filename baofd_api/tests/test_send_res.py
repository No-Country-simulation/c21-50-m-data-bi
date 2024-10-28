import os
import boto3
import pytest

from moto import mock_aws
from app.send_res import save_data_from_request

@pytest.fixture
def s3_setup():
    with mock_aws():
        s3 = boto3.client('s3', region_name='us-east-1')
        yield s3

def test_save_data_from_request(s3_setup):
    bucket_name = 'bank-account-opening-fraud-detection-data-ingestion-ml-api'
    file_home = "/home/robert/Downloads/test_file_result.csv"

    # s3_setup.create_bucket(Bucket=bucket_name)

    res = save_data_from_request(file_home, bucket_name)

    response = s3_setup.list_objects_v2(Bucket=bucket_name)
    
    assert res == True
    assert 'Contents' in response
    # assert any(obj['Key'] == 'test_file_result.csv' for obj in response['Contents'])
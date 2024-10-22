# Dataset for Crawler processing in S3
resource "aws_s3_bucket" "baofd_dataset_bucket" {
  bucket        = var.dataset_bucket
  force_destroy = true

  tags = {
    Name        = "Dataset bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "baofd_dataset_bucket_versioning" {
  bucket = aws_s3_bucket.baofd_dataset_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "baofd_dataset_dir" {
  bucket                 = aws_s3_bucket_versioning.baofd_dataset_bucket_versioning.id
  server_side_encryption = "aws:kms"
  key                    = "baofd-dataset/base-dataset/"
}

# Glue Job source code S3 bucket
resource "aws_s3_bucket" "baofd_glue_job_bucket" {
  bucket = var.glue_job_bucket

  tags = {
    Name        = "Glue job bucket"
    Environment = "Dev"
  }
}

# Glue Job source code
resource "aws_s3_object" "test_deploy_script_s3" {
  bucket = var.glue_job_bucket
  key    = "glue/scripts/main.py"
  source = "${local.glue_src_path}main.py"
  etag   = filemd5("${local.glue_src_path}main.py")

  depends_on = [
    aws_s3_bucket.baofd_glue_job_bucket
  ]
}

# Variables
locals {
  glue_src_path = "${path.root}/glue_etl/glue/"
}

variable "glue_job_bucket" {
  type = string
}

variable "dataset_bucket" {
  type = string
}
# Dataset for Crawler processing in S3
resource "aws_s3_bucket" "baofd_dataset_bucket" {
  bucket = var.dataset_bucket

  tags = {
    Name        = "Dataset bucket"
    Environment = "Dev"
  }
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
  key    = "glue/scripts/TestDeployScript.py"
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

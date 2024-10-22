terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# S3 buckets for dataset and source code
module "s3_data_ingestion" {
  source          = "./s3"
  glue_job_bucket = var.glue_job_bucket
  dataset_bucket  = var.dataset_bucket
}

# Glue ETL process
module "glue_etl" {
  source             = "./glue_etl/terraform"
  project            = var.project
  glue_job_name      = var.glue_job_name
  glue_database_name = var.glue_database_name
  glue_table_name    = var.glue_table_name
  glue_crawler_name  = var.glue_crawler_name
  glue_job_bucket    = var.glue_job_bucket
  dataset_bucket     = var.dataset_bucket
}

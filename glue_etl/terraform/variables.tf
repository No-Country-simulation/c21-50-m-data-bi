# Variables for the Glue implementation
locals {
  glue_src_path = "${path.root}/glue_etl/glue/"
}

variable "project" {
  type = string
}

variable "glue_job_name" {
  type = string
}

variable "glue_database_name" {
  type = string
}

variable "glue_table_name" {
  type = string
}

variable "glue_crawler_name" {
  type = string
}

variable "glue_job_bucket" {
  type = string
}

variable "dataset_bucket" {
  type = string
}

variable "glue_crawler_policies" {
  type        = set(string)
  default     = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]
  description = "Policies that will be attached to the Glue Crawler role"
}

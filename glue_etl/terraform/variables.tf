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

variable "glue_job_bucket" {
  type = string
}

variable "dataset_bucket" {
  type = string
}
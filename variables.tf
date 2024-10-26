variable "project" {
  type    = string
  default = "bank-account-opening-fraud-detection"
}

# Glue variables
variable "glue_job_name" {
  type        = string
  description = "Glue name."
  default     = "baofd-glue-etl-job"
}

variable "glue_job_bucket" {
  type        = string
  description = "Principal S3 bucket for glue job development."
  default     = "bank-account-opening-fraud-detection-glue-job-code"
}

variable "dataset_bucket" {
  type        = string
  description = "Principal S3 bucket for the dataset needed in the project."
  default     = "bank-account-opening-fraud-detection-s3-dataset"
}
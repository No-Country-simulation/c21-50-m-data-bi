# Data Catalog
resource "aws_glue_catalog_database" "baofd_database" {
  name = var.glue_database_name
}

# Crawler structure
resource "aws_glue_crawler" "baofd_dataset_structure" {
  database_name = aws_glue_catalog_database.baofd_database.name
  name          = var.glue_crawler_name
  role          = aws_iam_role.glue_crawler_service_role.arn
  table_prefix  = var.glue_table_name
  tags = {
    project = var.project
  }

  s3_target {
    path = "s3://${var.dataset_bucket}/baofd-dataset/base-dataset/"
  }
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "glue_etl_logs" {
  name              = "etl_process_glue_logs"
  retention_in_days = 1
}

# Glue Job
resource "aws_glue_job" "glue_etl_job_process" {
  glue_version      = "4.0"
  max_retries       = 0
  name              = var.glue_job_name
  description       = "ETL process with AWS Glue with datasets obtained from Kaggle about Bank Account Opening Fraud Detection. Transformed data will be moved to Redshift."
  role_arn          = aws_iam_role.glue_job_service_role.arn
  number_of_workers = 2
  worker_type       = "G.1X"
  timeout           = "30"
  execution_class   = "FLEX"
  tags = {
    project = var.project
  }

  command {
    name            = "glueetl"
    script_location = "s3://${var.glue_job_bucket}/glue/scripts/main.py"
  }

  default_arguments = {
    "--class"                            = "GlueApp"
    "--enable-job-insights"              = "true"
    "--enable-auto-scaling"              = "false"
    "--enable-glue-datacatalog"          = "true"
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--datalake-formats"                 = "iceberg"
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.glue_etl_logs.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
    "--conf"                             = "spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions  --conf spark.sql.catalog.glue_catalog=org.apache.iceberg.spark.SparkCatalog  --conf spark.sql.catalog.glue_catalog.warehouse=s3://tnt-erp-sql/ --conf spark.sql.catalog.glue_catalog.catalog-impl=org.apache.iceberg.aws.glue.GlueCatalog  --conf spark.sql.catalog.glue_catalog.io-impl=org.apache.iceberg.aws.s3.S3FileIO"

  }
}
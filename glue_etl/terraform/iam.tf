# Assume role for Glue
data "aws_iam_policy_document" "glue_execution_assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

# Read and write to specific S3 bucket
data "aws_iam_policy_document" "glue_etl_policy" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.glue_job_bucket}/*"]

    actions = ["s3:ListObject", "s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
  }

  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.glue_job_bucket}/", "arn:aws:s3:::${var.dataset_bucket}/"]

    actions = ["s3:ListObject"]
  }

  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.dataset_bucket}/"]

    actions = ["s3:GetObject"]
  }
}

# IAM Policy to access the principal S3 bucket
resource "aws_iam_policy" "glue_etl_access_policy" {
  name        = "s3GlueETLPolicy-${var.glue_job_bucket}"
  description = "Allows for running glue jobs in the glue console and access my S3 bucket."
  policy      = data.aws_iam_policy_document.glue_etl_policy.json
  tags = {
    Application = var.project
  }
}

# IAM Role for Glue
resource "aws_iam_role" "glue_service_role" {
  name               = "aws_glue_job_runner"
  assume_role_policy = data.aws_iam_policy_document.glue_execution_assume_role_policy.json
  tags = {
    Application = var.project
  }
}

# Attach Glue IAM role to the principal S3 bucket 
resource "aws_iam_role_policy_attachment" "glue_etl_permissions" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_etl_access_policy.arn
}
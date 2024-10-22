# Assume role for Glue Crawler
data "aws_iam_policy_document" "glue_crawler_assume_role_policy" {
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

# IAM Role for Glue Crawler
resource "aws_iam_role" "glue_crawler_service_role" {
  name               = "aws_glue_crawler_runner"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_assume_role_policy.json
  tags = {
    Application = var.project
  }
}

# Attach multiple AWS-managed policies for Glue Crawler
resource "aws_iam_role_policy_attachment" "glue_crawler_policy_attachment" {
  for_each   = var.glue_crawler_policies
  role       = aws_iam_role.glue_crawler_service_role.name
  policy_arn = each.value
}
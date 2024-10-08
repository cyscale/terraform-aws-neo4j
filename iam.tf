locals {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    aws_iam_policy.cw_retention.arn,
    aws_iam_policy.s3_backup.arn,
  ]
}

resource "aws_iam_policy" "cw_retention" {
  name        = "CloudWatchAgentPutLogsRetention"
  description = "Allow the CW agent to change retention policies"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:PutRetentionPolicy",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "s3_backup" {
  name        = "CyscaleS3Backup"
  description = "Allow managing of backups on S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.backup_bucket}/*"
      },
    ]
  })
}

resource "aws_iam_role" "neo4j_ec2_role" {
  name               = "${var.prefix}-role"
  assume_role_policy = local.assume_role_policy
}

resource "aws_iam_instance_profile" "neo4j_instance_profile" {
  name = "${var.prefix}-profile"
  role = aws_iam_role.neo4j_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "this" {
  count = length(local.role_policy_arns)

  role       = aws_iam_role.neo4j_ec2_role.name
  policy_arn = element(local.role_policy_arns, count.index)
}

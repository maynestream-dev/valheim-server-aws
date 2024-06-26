resource "aws_s3_bucket" "valheim" {
  bucket = local.name
  tags   = local.tags
}

resource "aws_s3_bucket_versioning" "valheim" {
  bucket = aws_s3_bucket.valheim.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "valheim" {
  bucket = aws_s3_bucket.valheim.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "valheim" {
  bucket = aws_s3_bucket.valheim.id

  rule {
    id     = "rule-1"
    status = "Enabled"

    expiration {
      days = var.s3_lifecycle_expiration
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "valheim" {
  bucket = aws_s3_bucket.valheim.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "valheim" {
  bucket = aws_s3_bucket.valheim.id
  policy = jsonencode({
    Version : "2012-10-17",
    Id : "PolicyForValheimBackups",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          "AWS" : aws_iam_role.valheim.arn
        },
        Action : [
          "s3:Put*",
          "s3:Get*",
          "s3:List*"
        ],
        Resource : "arn:aws:s3:::${aws_s3_bucket.valheim.id}/*"
      }
    ]
  })

  // https://github.com/hashicorp/terraform-provider-aws/issues/7628
  depends_on = [aws_s3_bucket_public_access_block.valheim]
}

resource "aws_s3_bucket_public_access_block" "valheim" {
  bucket = aws_s3_bucket.valheim.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "install_valheim" {
  bucket         = aws_s3_bucket.valheim.id
  key            = "/install_valheim.sh"
  content_base64 = base64encode(templatefile("${path.module}/local/install_valheim.sh", {
    username                  = local.username
    additional_steam_cmd_args = var.additional_steam_cmd_args
  }))
  etag           = filemd5("${path.module}/local/install_valheim.sh")
}

resource "aws_s3_object" "bootstrap_valheim" {
  bucket = aws_s3_bucket.valheim.id
  key    = "/bootstrap_valheim.sh"
  content_base64 = base64encode(templatefile("${path.module}/local/bootstrap_valheim.sh", {
    username = local.username
    bucket   = aws_s3_bucket.valheim.id
  }))
  etag = filemd5("${path.module}/local/bootstrap_valheim.sh")
}

resource "aws_s3_object" "start_valheim" {
  bucket = aws_s3_bucket.valheim.id
  key    = "/start_valheim.sh"
  content_base64 = base64encode(templatefile("${path.module}/local/start_valheim.sh", {
    username                  = local.username
    bucket                    = aws_s3_bucket.valheim.id
    world_name                = var.world_name
    server_name               = var.server_name
    server_password           = var.server_password
  }))
  etag = filemd5("${path.module}/local/start_valheim.sh")
}

resource "aws_s3_object" "backup_valheim" {
  bucket = aws_s3_bucket.valheim.id
  key    = "/backup_valheim.sh"
  content_base64 = base64encode(templatefile("${path.module}/local/backup_valheim.sh", {
    username    = local.username
    bucket      = aws_s3_bucket.valheim.id
    server_name = var.server_name
    world_name  = var.world_name
  }))
  etag = filemd5("${path.module}/local/backup_valheim.sh")
}

resource "aws_s3_object" "crontab" {
  bucket         = aws_s3_bucket.valheim.id
  key            = "/crontab"
  content_base64 = base64encode(templatefile("${path.module}/local/crontab", {
    username = local.username 
  }))
  etag           = filemd5("${path.module}/local/crontab")
}

resource "aws_s3_object" "valheim_service" {
  bucket = aws_s3_bucket.valheim.id
  key    = "/valheim.service"
  content_base64 = base64encode(templatefile("${path.module}/local/valheim.service", {
    username = local.username
  }))
  etag = filemd5("${path.module}/local/valheim.service")
}

resource "aws_s3_object" "admin_list" {
  bucket         = aws_s3_bucket.valheim.id
  key            = "/adminlist.txt"
  content_base64 = base64encode(templatefile("${path.module}/local/adminlist.txt", {
    admins = values(var.admins)
  }))
  etag           = filemd5("${path.module}/local/adminlist.txt")
}

resource "aws_iam_role" "valheim" {
  name = "${local.name}-server"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
  tags = local.tags
}

resource "aws_iam_instance_profile" "valheim" {
  role = aws_iam_role.valheim.name
}

resource "aws_iam_policy" "valheim" {
  name        = "${local.name}-server"
  description = "Allows the Valheim server to interact with various AWS services"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "s3:Put*",
          "s3:Get*",
          "s3:List*"
        ],
        Resource : [
          "arn:aws:s3:::${aws_s3_bucket.valheim.id}",
          "arn:aws:s3:::${aws_s3_bucket.valheim.id}/"
        ]
      },
      {
        Effect : "Allow",
        Action : ["ec2:DescribeInstances"],
        Resource : ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "valheim" {
  role       = aws_iam_role.valheim.name
  policy_arn = aws_iam_policy.valheim.arn
}

resource "aws_security_group" "ingress" {
  name        = "${local.name}-ingress"
  description = "Security group allowing inbound traffic to the Valheim server"
  tags        = local.tags
}

resource "aws_security_group_rule" "valheim_ingress" {
  type              = "ingress"
  from_port         = 2456
  to_port           = 2458
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress.id
  description       = "Allows traffic to the Valheim server"
}

resource "aws_security_group_rule" "netdata" {
  type              = "ingress"
  from_port         = 19999
  to_port           = 19999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress.id
  description       = "Allows traffic to the Netdata dashboard"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress.id
  description       = "Allow all egress rule for the Valheim server"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.*-amd64-server-*"]
  }
}

resource "aws_spot_instance_request" "valheim" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  ebs_optimized = true
  user_data = templatefile("${path.module}/local/userdata.sh", {
    username = local.username
    bucket   = aws_s3_bucket.valheim.id
  })
  iam_instance_profile           = aws_iam_instance_profile.valheim.name
  vpc_security_group_ids         = [aws_security_group.ingress.id]
  wait_for_fulfillment           = true
  instance_interruption_behavior = "stop"
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = local.ec2_tags

  depends_on = [
    aws_s3_object.install_valheim,
    aws_s3_object.start_valheim,
    aws_s3_object.backup_valheim,
    aws_s3_object.crontab,
    aws_s3_object.valheim_service,
    aws_s3_object.admin_list
  ]
}

resource "aws_ec2_tag" "valheim" {
  for_each = local.ec2_tags

  resource_id = aws_spot_instance_request.valheim.spot_instance_id
  key         = each.key
  value       = each.value
}

locals {
  username = "vhserver"
  tags = {
    "Component" = "Valheim Server"
    "CreatedBy" = "Terraform"
  }
  ec2_tags = merge(local.tags,
    {
      "Name"        = "${local.name}-server"
      "Description" = "Instance running a Valheim server"
    }
  )
  name = "${var.server_name}"
}

variable "aws_region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "server_name" {
  type = string
}

variable "server_password" {
  type = string
}

variable "world_name" {
  type = string
}

variable "additional_steam_cmd_args" {
  type = string
}

variable "admins" {
  type = map(any)
}

variable "s3_lifecycle_expiration" {
  type = string
}

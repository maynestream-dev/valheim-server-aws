module "main" {
  source = "../module"

  aws_region                = var.aws_region
  instance_type             = var.instance_type
  server_name               = var.server_name
  server_password           = var.server_password
  world_name                = var.world_name
  additional_steam_cmd_args = var.additional_steam_cmd_args
  admins                    = var.admins
  s3_lifecycle_expiration   = var.s3_lifecycle_expiration
}

variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "The AWS region to create the Valheim server"
}

variable "server_name" {
  type        = string
  default     = "valheim"
  description = "The server name"
}

variable "server_password" {
  type        = string
  description = "The server password"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "AWS EC2 instance type to run the server on (t3a.medium is the minimum size)"
}

variable "world_name" {
  type        = string
  default     = "Dedicated"
  description = "The Valheim world name"
}

variable "additional_steam_cmd_args" {
  type = string
  default = ""
}

variable "admins" {
  type        = map(any)
  default     = { "default_valheim_user" = "", }
  description = "List of AWS users/Valheim server admins (use their SteamID)"
}

variable "s3_lifecycle_expiration" {
  type        = string
  default     = "90"
  description = "The number of days to keep files (backups) in the S3 bucket before deletion"
}

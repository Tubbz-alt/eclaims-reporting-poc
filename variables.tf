variable "env" {
  default = "sandpit"
}

variable "is_production" {
  default = "false"
}

variable "project_name" {
  default = "mhclg-eclaims-reporting-poc"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "s3_bucket_region" {
  default = "eu-west-1"
}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "rds_database_name" {}

variable "rds_master_username" {}

variable "rds_master_password" {}

variable "vpc_id" {
  # used for the S3 VPC endpoint
}

# variable "rds_vpc_security_group_ids" {}
# 
# variable "glue_database_name" {
#   default = "mhclg-reporting-test-s3-crawler-db"
# }

# variable "glue_connection_db_password" {}
# variable "glue_connection_db_username" {}

variable "s3_bucket_name" {}

variable "tags" {
  type = "map"

  default = {
    "Production"  = "false"
    "project"     = "reporting-poc"
    "environment" = "dev"
  }
}

variable "aws_instance_type" {
  default = "micro"
}

#
# variable "aws_key_name" {}
# variable "aws_key_path" {}
#
# variable "docker_image_name" {
#   default = "communitiesgovuk/eclaims-reporting-poc"
# }
#
# variable "container_name" {
#   default = "update-reporting-db"
# }
#
# variable "local_env_file_path" {
#   default = "/etc/update-reporting-db.env"
# }


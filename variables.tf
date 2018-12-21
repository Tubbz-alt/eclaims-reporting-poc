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

variable "glue_database_name" {
  default = "mhclg-reporting-test-s3-crawler-db"
}

variable "glue_connection_db_password" {}
variable "glue_connection_db_username" {}

variable "s3_bucket_name" {}

variable "tags" {
  type = "map"

  default = {
    "Production"  = "false"
    "project"     = "reporting-poc"
    "environment" = "dev"
  }
}

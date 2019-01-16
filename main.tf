provider "aws" {
  region = "${var.aws_region}"
}

# Read the properties of the VPC with the given ID
# and we can then calculate CIDR blocks from that
data "aws_vpc" "given" {
  id = "${var.vpc_id}"
}

data "aws_subnet" "subnet_1" {
  vpc_id = "${var.vpc_id}"

  filter {
    name   = "tag:Name"
    values = ["MHCLG-TESTRDS-PrivateA"]
  }
}

data "aws_subnet" "subnet_2" {
  vpc_id = "${var.vpc_id}"

  filter {
    name   = "tag:Name"
    values = ["MHCLG-TESTRDS-PrivateB"]
  }
}

data "aws_subnet" "subnet_3" {
  vpc_id = "${var.vpc_id}"

  filter {
    name   = "tag:Name"
    values = ["MHCLG-TESTRDS-PrivateC"]
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Our main group of subnets"

  subnet_ids = [
    "${data.aws_subnet.subnet_1.id}",
    "${data.aws_subnet.subnet_2.id}",
    "${data.aws_subnet.subnet_3.id}",
  ]
}

# Target RDS instance for the reporting data
resource "aws_db_instance" "rds_reporting_data" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "${var.rds_instance_type}"
  identifier             = "eclaimsreportingpocdb${var.env}"
  name                   = "eclaimsreportingpocdb${var.env}"
  username               = "${var.rds_master_username}"
  password               = "${var.rds_master_password}"
  publicly_accessible    = "false"
  vpc_security_group_ids = ["${aws_security_group.ingress_on_all_ports_from_within_sg.id}"]
  skip_final_snapshot    = "true"

  db_subnet_group_name = "${aws_db_subnet_group.default.id}"

  tags = {
    "production"  = "${var.is_production}"
    "project"     = "${var.project_name}"
    "environment" = "${var.env}"
    "Name"        = "eclaimsreportingpocdb${var.env}"
  }
}

# TODO
# No way to automatically create the actual postgres database
# within the instance (or the db user we need for the glue crawler)
# - maybe via remote_exec on an ec2 instance?

# S3 Bucket to hold the source data - we assume this is setup
# outside of terraform
data "aws_s3_bucket" "source_data" {
  bucket = "${var.s3_bucket_name}"
}

# A security group that allows ingress on all ports
# from anything within that same SG. The SG must be applied to the
# RDS instance, and if we're using Glue, the Glue job
resource "aws_security_group" "ingress_on_all_ports_from_within_sg" {
  name        = "allow_all_from_sg"
  description = "Allow all inbound traffic from within same sg"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "TCP"
    self      = "true"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "production"  = "${var.is_production}"
    "project"     = "${var.project_name}"
    "environment" = "${var.env}"
  }
}

# This code copied from
# https://github.com/binarymist/aws-docker-host/blob/master/tf/instance_creation/instance.tf
# get the most recent Canonical Ubuntu AMI
# data "aws_ami" "ubuntu" {
#   most_recent = true
#
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
#   }
#
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#
#   owners = ["099720109477"] # Canonical
# }
#
# resource "aws_instance" "dockerhost" {
#   ami           = "${data.aws_ami.ubuntu.id}"
#   instance_type = "${var.aws_instance_type}"
#
#   tags {
#     Name = "dockerhost"
#   }
#
#   vpc_security_group_ids = ["${aws_security_group.ingress_on_all_ports_from_within_sg.id}"]
#
#   # Copy public key to instance.
#   # key_name = "${var.aws_key_name}"
#
#   # connection {
#   #   type = "ssh"
#   #
#   #   #agent = false
#   #   user        = "${var.instance_user}"
#   #   private_key = "${file("${var.key_pair["private_key_file_path"]}")}"
#   #   timeout     = "3m"
#   # }
#   provisioner "file" {
#     # setup /etc/update-reporting-db.env with required env vars
#     destination = "${var.local_env_file_path}"
#
#     content = <<EOF
# DATABASE_URL=postgres://${var.rds_master_username}:${var.rds_master_password}@${aws_db_instance.rds_reporting_data.endpoint}/${aws_db_instance.rds_reporting_data.name}?pool=5
# S3_BUCKET_NAME=${var.s3_bucket_name}
# S3_BUCKET_REGION=${var.s3_bucket_region}
# EOF
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "echo \"##### Performing apt-get update #####\"",
#       "sudo apt-get update",
#       "echo \"##### Installing packages #####\"",
#       "sudo apt-get install -y docker",
#       "sudo service docker start",
#     ]
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "docker pull ${var.docker_image_name}",
#       "docker run --env-file ${var.local_env_file_path} --name ${var.container_name} ${var.docker_image_name}",
#     ]
#   }
# }


# Glue needs a VPC endpoint to read data from the bucket
# resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
#   vpc_id          = "${var.vpc_id}"
#   service_name    = "com.amazonaws.${var.aws_region}.s3"
#   route_table_ids = []
# }


# QuickSight needs a security group adding to the RDS instance that grants
# ingress on all ports to anything within the CIDR range used by QuickSight
# https://docs.aws.amazon.com/quicksight/latest/user/enabling-access-rds.html
# resource "aws_security_group" "ingress_on_all_ports_from_quicksight" {
#   name        = "allow_all_from_quicksight"
#   description = "Allow all inbound traffic from quicksight"
#   vpc_id      = "${var.vpc_id}"
#
#   ingress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "TCP"
#     cidr_blocks = ["52.210.255.224/27"] # <- Quicksight Ireland
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     "production"  = "${var.is_production}"
#     "project"     = "${var.project_name}"
#     "environment" = "${var.env}"
#   }
# }


# We need to reference 2 existing IAM policies
# data "aws_iam_policy" "s3_full_access" {
#   arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }
#
# data "aws_iam_policy" "glue_service_role" {
#   arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
# }


# IAM role to grant full access to S3 for Glue
# resource "aws_iam_role" "glue_s3_access_role" {
#   name = "s3_full_access"
#
#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": "sts:AssumeRole",
#         "Principal": {
#           "AWS": "*"
#         },
#         "Effect": "Allow",
#         "Sid": ""
#       }
#     ]
#   }
# EOF
#
#   tags = {
#     "production"  = "${var.is_production}"
#     "project"     = "${var.project_name}"
#     "environment" = "${var.env}"
#   }
# }
#
# resource "aws_iam_role_policy_attachment" "glue_s3_access_role_attachment" {
#   role       = "${aws_iam_role.glue_s3_access_role.name}"
#   policy_arn = "${data.aws_iam_policy.s3_full_access.arn}"
# }
#
# resource "aws_iam_role_policy_attachment" "glue_service_role_attachment" {
#   role       = "${aws_iam_role.glue_s3_access_role.name}"
#   policy_arn = "${data.aws_iam_policy.glue_service_role.arn}"
# }


# Glue resources
# resource "aws_glue_catalog_database" "reporting_glue_db" {
#   name = "${var.glue_database_name}"
# }
#
# resource "aws_glue_catalog_table" "crawled_xml_catalog_table" {
#   name          = "crawled-xml"
#   database_name = "${aws_glue_catalog_database.reporting_glue_db.name}"
# }


# resource "aws_glue_connection" "glue_rds_connection" {
#   connection_properties = {
#     JDBC_CONNECTION_URL = "jdbc:postgresql://${aws_db_instance.rds_reporting_data.endpoint}/${var.rds_database_name}"
#     PASSWORD            = "${var.glue_connection_db_password}"
#     USERNAME            = "${var.glue_connection_db_username}"
#   }
#
#   name = "reporting-glue-db-connection-${var.env}"
#
#   physical_connection_requirements {
#     availability_zone      = "${aws_db_instance.rds_reporting_data.availability_zone}"
#     security_group_id_list = ["${aws_security_group.ingress_on_all_ports_from_within_sg.id}"]
#
#     # subnet_id              = "${aws_subnet.example.id}"
#   }
# }


# resource "aws_glue_classifier" "claim_xml_classifier" {
#   name = "claims-xml-classifier"
#
#   xml_classifier {
#     classification = "eclaims-claim-view"
#     row_tag        = "claim"
#   }
# }


# resource "aws_glue_crawler" "example" {
#   database_name = "${aws_glue_catalog_database.reporting_glue_db.name}"
#   name          = "s3-claim-csv-crawler"
#   role          = "${aws_iam_role.glue_s3_access_role.arn}"
#   classifiers   = ["claim-csv-classifier", "claim-line-csv-classifier"]
#
#   s3_target {
#     path = "s3://${data.aws_s3_bucket.source_data.bucket}/csv"
#   }
# }


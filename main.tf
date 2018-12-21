provider "aws" {}

# Target RDS instance for the reporting data
resource "aws_db_instance" "rds_reporting_data" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "${var.rds_instance_type}"
  name                   = "eclaimsreportingdb${var.env}"
  username               = "${var.rds_master_username}"
  password               = "${var.rds_master_password}"
  publicly_accessible    = "false"
  vpc_security_group_ids = ["${aws_security_group.ingress_on_all_ports_from_within_sg.id}"]
  skip_final_snapshot    = "true"

  tags = {
    "production"  = "${var.is_production}"
    "project"     = "${var.project_name}"
    "environment" = "${var.env}"
  }
}

# TODO
# No way to automatically create the actual postgres database
# within the instance, or the user we need for the glue crawler
#

# S3 Bucket to hold the source data - we assume this is setup
# outside of terraform
data "aws_s3_bucket" "source_data" {
  bucket = "${var.s3_bucket_name}"
}

# Glue needs a VPC endpoint to read data from the bucket
resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  vpc_id          = "${var.vpc_id}"
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = []
}

# Glue connection needs a security group that allows ingress on all ports
# from anything within that same SG. The SG must be applied to the
# RDS instance as well as the Glue job
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

# QuickSight needs a security group adding to the RDS instance that grants
# ingress on all ports to anything within the CIDR range used by QuickSight
# https://docs.aws.amazon.com/quicksight/latest/user/enabling-access-rds.html
resource "aws_security_group" "ingress_on_all_ports_from_quicksight" {
  name        = "allow_all_from_quicksight"
  description = "Allow all inbound traffic from quicksight"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["52.210.255.224/27"] # <- Quicksight Ireland
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

# We need to reference 2 existing IAM policies
data "aws_iam_policy" "s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "glue_service_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# IAM role to grant full access to S3 for Glue
resource "aws_iam_role" "glue_s3_access_role" {
  name = "s3_full_access"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": "*"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
EOF

  tags = {
    "production"  = "${var.is_production}"
    "project"     = "${var.project_name}"
    "environment" = "${var.env}"
  }
}

resource "aws_iam_role_policy_attachment" "glue_s3_access_role_attachment" {
  role       = "${aws_iam_role.glue_s3_access_role.name}"
  policy_arn = "${data.aws_iam_policy.s3_full_access.arn}"
}

resource "aws_iam_role_policy_attachment" "glue_service_role_attachment" {
  role       = "${aws_iam_role.glue_s3_access_role.name}"
  policy_arn = "${data.aws_iam_policy.glue_service_role.arn}"
}

# Glue resources
resource "aws_glue_catalog_database" "reporting_glue_db" {
  name = "${var.glue_database_name}"
}

resource "aws_glue_catalog_table" "crawled_xml_catalog_table" {
  name          = "crawled-xml"
  database_name = "${aws_glue_catalog_database.reporting_glue_db.name}"
}

resource "aws_glue_connection" "glue_rds_connection" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://${aws_db_instance.rds_reporting_data.endpoint}/${var.rds_database_name}"
    PASSWORD            = "${var.glue_connection_db_password}"
    USERNAME            = "${var.glue_connection_db_username}"
  }

  name = "reporting-glue-db-connection-${var.env}"

  physical_connection_requirements {
    availability_zone      = "${aws_db_instance.rds_reporting_data.availability_zone}"
    security_group_id_list = ["${aws_security_group.ingress_on_all_ports_from_within_sg.id}"]

    # subnet_id              = "${aws_subnet.example.id}"
  }
}

resource "aws_glue_classifier" "claim_xml_classifier" {
  name = "claims-xml-classifier"

  xml_classifier {
    classification = "eclaims-claim-view"
    row_tag        = "claim"
  }
}

resource "aws_glue_crawler" "example" {
  database_name = "${aws_glue_catalog_database.reporting_glue_db.name}"
  name          = "s3-xml-crawler"
  role          = "${aws_iam_role.glue_s3_access_role.arn}"
  classifiers   = ["claim-xml-classifier"]

  s3_target {
    path = "s3://${data.aws_s3_bucket.source_data.bucket}/xml"
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      region = "us-east-1"
    }
  }
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-app-sandbox-eks"
  cluster_version = "1.29"
  subnets         = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  vpc_id = "vpc-12345678"

  node_groups = {
    example = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "m4.large"
    }
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-12345678"

  ingress {
    from_port   = 0
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "example_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  db_name                = "my-app-sandbox-db"
  username               = "admin"
  password               = "Sup3rP4$$w0rd"
  parameter_group_name   = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
}

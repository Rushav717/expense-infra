module "vpc" {
  source               = "git::https://github.com/Rushav717/terraform-aws-vpc.git?ref=main"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  common_tags          = var.common_tags
  vpc_tags             = var.vpc_tags
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  db_subnet_cidrs      = var.db_subnet_cidrs
  is_peering_required  = var.is_peering_required
}

resource "aws_db_subnet_group" "expense" {
  name       = "${var.project_name}-${var.environment}"
  subnet_ids = module.vpc.db_subnet_ids

  tags = merge(
    var.common_tags,
   {
    Name = "${var.project_name}-${var.environment}"
  }
  )
}
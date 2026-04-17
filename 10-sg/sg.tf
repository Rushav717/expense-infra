module "mysql_sg" {
  source         = "git::https://github.com/Rushav717/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name
  environment    = var.environment
  sg_name        = "mysql"
  sg_description = "SG created for mysql instances in expense dev"
  common_tags    = var.common_tags
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

module "bastion_sg" {
  source         = "git::https://github.com/Rushav717/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name
  environment    = var.environment
  sg_name        = "bastion"
  sg_description = "SG created for bastion instances in expense dev"
  common_tags    = var.common_tags
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

#ports for vpn: 22,443,1194,943
module "vpn_sg" {
  source         = "git::https://github.com/Rushav717/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name
  environment    = var.environment
  sg_name        = "vpn"
  sg_description = "created for vpn in expense dev"
  common_tags    = var.common_tags
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

module "alb_ingress_sg" {
  source         = "git::https://github.com/Rushav717/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name #expense
  environment    = var.environment #dev
  sg_name        = "alb_ingress"   
  sg_description = "SG created for backend alb in expense dev"
  common_tags    = var.common_tags
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

module "eks_control_plane_sg" {
  source         = "git::https://github.com/Rushav717/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name #expense
  environment    = var.environment #dev
  sg_name        = "eks_control_plane"   
  sg_description = "SG created for backend alb in expense dev"
  common_tags    = var.common_tags
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

module "eks_nodes_sg" {
  source         = "git::https://github.com/Rushav717/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name #expense
  environment    = var.environment #dev
  sg_name        = "eks_nodes"   
  sg_description = "SG created for backend alb in expense dev"
  common_tags    = var.common_tags
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_security_group_rule" "eks_control_plane_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.eks_nodes_sg.sg_id
  security_group_id        = module.eks_control_plane_sg.sg_id
}

resource "aws_security_group_rule" "nodes_eks_control_plane" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.eks_control_plane_sg.sg_id
  security_group_id        = module.eks_nodes_sg.sg_id
}

resource "aws_security_group_rule" "nodes_alb_ingress" {
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  source_security_group_id = module.alb_ingress_sg.sg_id
  security_group_id        = module.eks_nodes_sg.sg_id
}

resource "aws_security_group_rule" "eks_nodes_vpc" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
  security_group_id        = module.eks_nodes_sg.sg_id
}

resource "aws_security_group_rule" "eks_nodes_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.eks_nodes_sg.sg_id
}


#application load balancer allowing traffic from bastion
resource "aws_security_group_rule" "alb_ingress_bastion" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.alb_ingress_sg.sg_id
}

resource "aws_security_group_rule" "alb_ingress_bastion_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.alb_ingress_sg.sg_id
}

resource "aws_security_group_rule" "alb_ingress_bastion_public_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id        = module.alb_ingress_sg.sg_id
}

#security group rule for bastion security group present in public subnet
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["124.123.128.159/32"] #dynamic IP, daily it will change, in companies it will be static
  security_group_id = module.bastion_sg.sg_id
}

#mysql allowing traffic from bastion
resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "mysql_eks_nodes" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.eks_nodes_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}
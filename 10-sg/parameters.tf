resource "aws_ssm_parameter" "mysql_sg_id" {
  name  = "/${var.project_name}/${var.environment}/mysql_sg_id"
  type  = "String"
  value = module.mysql_sg.sg_id
}

resource "aws_ssm_parameter" "bastion_sg_id" {
  name  = "/${var.project_name}/${var.environment}/bastion_sg_id"
  type  = "String"
  value = module.bastion_sg.sg_id
}

resource "aws_ssm_parameter" "alb_ingress_sg_id" {
  name  = "/${var.project_name}/${var.environment}/alb_ingress_sg_id"
  type  = "String"
  value = module.alb_ingress_sg.sg_id
}

resource "aws_ssm_parameter" "eks_control_plane_sg" {
  name  = "/${var.project_name}/${var.environment}/eks_control_plane_sg_id"
  type  = "String"
  value = module.eks_control_plane_sg.sg_id
}

resource "aws_ssm_parameter" "eks_nodes_sg" {
  name  = "/${var.project_name}/${var.environment}/eks_nodes_sg_id"
  type  = "String"
  value = module.eks_nodes_sg.sg_id
}
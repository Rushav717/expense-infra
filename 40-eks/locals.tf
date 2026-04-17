locals {
  name = "${var.project_name}-${var.environment}"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  node_id = data.aws_ssm_parameter.eks_nodes_sg.value
  control_plane_id = data.aws_ssm_parameter.eks_control_plane_sg.value
}
resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = file("${path.module}/daws-82s.pub")
  }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.name
  kubernetes_version = "1.32" #later we upgrade to 1.33
 


  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
         before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
        before_compute = true
    }
    metrics-server = {}
  }

  endpoint_public_access = false
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids
  create_node_security_group = false
  create_security_group = false
  node_security_group_id = local.node_id
  security_group_id = local.control_plane_id

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies  = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
      }
    }
  }
 tags = merge(
    var.common_tags,
   {
    Name = local.name
  }
  )
}
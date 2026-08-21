module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.common_name
  kubernetes_version = "1.34"

  # Mandatory
  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access = false

  #By default admin access will be granted for who created it
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  create_node_security_group = false
  create_security_group = false

  node_security_group_id = local.eks_node_sg_id
  security_group_id = local.eks_control_plane_sg_id


  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small","t3.medium"]
      capacity_type = "SPOT"

      iam_role_additional_policies = {
        EBS = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"
        EFS = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
      }
      min_size     = 2
      max_size     = 5
      desired_size = 3

      # This is required AWS LoadBalancerController
      metadata_options = {
        http_endpoint = "enabled"
        http_put_response_hop_limit = 2
        http_tokens = "required"
      }
    }
  }

  tags = local.common_tags
}
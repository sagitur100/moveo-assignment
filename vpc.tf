# These module create 
#
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "nginx-docker"
  cidr = "10.0.0.0/16"

  azs             = var.azs
  private_subnets = ["10.0.11.0/24", "10.0.111.0/24"]
  public_subnets  = ["10.0.12.0/24", "10.0.112.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  
}


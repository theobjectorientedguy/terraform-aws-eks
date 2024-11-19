
provider "aws" {
  region = var.aws_region 
}


# Call the VPC module to create the VPC
module "vpc" {
  source     = "./modules/vpc"    # Path to the VPC module
  cidr_block = "10.0.0.0/16"      # CIDR block for the VPC (range of IPs it can use)
  tags = {                         # Tags to label the VPC for easier identification
    Name = "my-vpc"
  }
}

# Public Subnet 1
module "public_subnet_1" {
  source                 = "./modules/subnet"    # Path to the subnet module
  vpc_id                 = module.vpc.vpc_id      # Pass the VPC ID from the VPC module
  cidr_block             = "10.0.1.0/24"          # CIDR block for the first public subnet
  map_public_ip_on_launch = true                   # Enable public IP assignment for instances
  availability_zone      = "us-east-1a"            # Availability zone where this subnet will reside
  tags = {
    Name = "public-subnet-1"  
  }
}

# Public Subnet 2
module "public_subnet_2" {
  source                 = "./modules/subnet"    # Path to the subnet module
  vpc_id                 = module.vpc.vpc_id      # Pass the VPC ID from the VPC module
  cidr_block             = "10.0.2.0/24"          # CIDR block for the second public subnet
  map_public_ip_on_launch = true                   # Enable public IP assignment for instances
  availability_zone      = "us-east-1b"            # Availability zone where this subnet will reside
  tags = {
    Name = "public-subnet-2"
  }
}

# Private Subnet 1
module "private_subnet_1" {
  source                 = "./modules/subnet"    # Path to the subnet module
  vpc_id                 = module.vpc.vpc_id      # Pass the VPC ID from the VPC module
  cidr_block             = "10.0.3.0/24"          # CIDR block for the first private subnet
  map_public_ip_on_launch = false                  # Disable public IP assignment (private subnet)
  availability_zone      = "us-east-1a"            # Availability zone where this subnet will reside
  tags = {
    Name = "private-subnet-1"  # Tags to name the subnet
  }
}

# Private Subnet 2
module "private_subnet_2" {
  source                 = "./modules/subnet"    # Path to the subnet module
  vpc_id                 = module.vpc.vpc_id      # Pass the VPC ID from the VPC module
  cidr_block             = "10.0.4.0/24"          # CIDR block for the second private subnet
  map_public_ip_on_launch = false                  # Disable public IP assignment (private subnet)
  availability_zone      = "us-east-1b"            # Availability zone where this subnet will reside
  tags = {
    Name = "private-subnet-2" 
  }
}


# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = module.vpc.vpc_id
}

# Create a route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = module.public_subnet_1.subnet_id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = module.public_subnet_2.subnet_id
  route_table_id = aws_route_table.public.id
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "EKSClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}


# Attach Policies to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}




# IAM Role for EKS Nodes
resource "aws_iam_role" "eks_node_role" {
  name = "EKSNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EKS Cluster Module
module "eks" {
  source            = "./modules/eks"
  cluster_name      = "my-eks-cluster"
  cluster_role_arn  = aws_iam_role.eks_cluster_role.arn
  subnet_ids        = [module.public_subnet_1.subnet_id, module.public_subnet_2.subnet_id]  # Use public subnets
  node_group_name   = "my-eks-node-group"
  node_role_arn     = aws_iam_role.eks_node_role.arn
  desired_size      = 1                      # Number of nodes
  max_size          = 1                      # Max nodes
  min_size          = 1                      # Min nodes
  instance_types    = ["t2.micro"]             # Free tier eligible instance type
}
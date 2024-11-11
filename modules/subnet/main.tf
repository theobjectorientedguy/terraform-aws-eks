resource "aws_subnet" "main" {
  vpc_id                  = var.vpc_id               # VPC ID where this subnet will be created (passed from the calling module)
  cidr_block              = var.cidr_block           # CIDR block for this subnet (e.g., "10.0.1.0/24")
  map_public_ip_on_launch = var.map_public_ip_on_launch  # Whether to assign a public IP to instances launched in this subnet
  availability_zone       = var.availability_zone    # Availability zone (e.g., "us-west-2a")

  # The tags are passed in from the calling module to label the subnet
  tags = var.tags
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.main.id
}

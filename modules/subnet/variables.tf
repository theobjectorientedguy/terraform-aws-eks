variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Whether to auto-assign public IPs (for public subnets)"
  type        = bool
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
}

variable "tags" {
  description = "Tags for the subnet"
  type        = map(string)
}
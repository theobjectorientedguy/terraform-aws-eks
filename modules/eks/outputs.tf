output "node_group_instance_types" {
  description = "Instance types used in the EKS node group"
  value       = aws_eks_node_group.this.instance_types
}

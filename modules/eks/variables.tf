   variable "cluster_name" {
     description = "The name of the EKS cluster"
     type        = string
   }

   variable "cluster_role_arn" {
     description = "The ARN of the IAM role associated with the EKS cluster"
     type        = string
   }

   variable "subnet_ids" {
     description = "List of subnet IDs for the EKS cluster"
     type        = list(string)
   }

   variable "tags" {
     description = "Tags to assign to the EKS cluster"
     type        = map(string)
   }

   variable "node_group_name" {
     description = "The name of the EKS Node Group"
     type        = string
   }

   variable "node_role_arn" {
     description = "The ARN of the IAM role for the EKS Node"
     type        = string
   }

   variable "desired_size" {
     description = "Desired number of nodes in the EKS node group"
     type        = number
   }

   variable "max_size" {
     description = "Maximum number of nodes in the EKS node group"
     type        = number
   }

   variable "min_size" {
     description = "Minimum number of nodes in the EKS node group"
     type        = number
   }
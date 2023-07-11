# output "eks_cluster_endpoint" {
#   value = aws_eks_cluster.aws_eks.endpoint
# }

# output "eks_cluster_certificate_authority" {
#   value = aws_eks_cluster.aws_eks.certificate_authority
# }

output "aws_subnet_id" {
  value = aws_subnet.private_subnets[1].id
}

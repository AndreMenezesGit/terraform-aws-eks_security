output "sec_master_sg_id" {
  value = aws_security_group.void-eks-master.*.id
}

output "sec_nodes_sg_id" {
  value = [aws_security_group.void-eks-node.*.id]
}

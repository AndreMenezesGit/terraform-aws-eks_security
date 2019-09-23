resource "aws_security_group" "void-eks-master" {
  name        = "${var.cluster-name}-master"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.aws_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster-name}-master"
  }
}

resource "aws_security_group" "void-eks-node" {
  name        = "${var.cluster-name}-nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.aws_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "${var.cluster-name}-nodes",
    "kubernetes.io/cluster/${var.cluster-name}" = "owned",
  }
}

resource "aws_security_group_rule" "void-eks-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.void-eks-node.id
  source_security_group_id = aws_security_group.void-eks-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "void-eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.void-eks-node.id
  source_security_group_id = aws_security_group.void-eks-master.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "void-eks-master-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.void-eks-master.id
  source_security_group_id = aws_security_group.void-eks-node.id
  to_port                  = 443
  type                     = "ingress"
}

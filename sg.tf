resource "aws_security_group" "alb_securityGP" {
  vpc_id = aws_vpc.ranjitvpc.id

}

resource "aws_vpc_security_group_ingress_rule" "alb_ingressTCP" {
  security_group_id = aws_security_group.alb_securityGP.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "TCP"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingressICMP" {
  security_group_id = aws_security_group.alb_securityGP.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "ICMP"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_egress_rule" "alb_egressSG" {
  security_group_id = aws_security_group.alb_securityGP.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "TCP"
  from_port         = 0
  to_port           = 65535

}

# Security group for ec2

resource "aws_security_group" "EC2_SG" {
  vpc_id = aws_vpc.ranjitvpc.id

}

resource "aws_vpc_security_group_ingress_rule" "EC2_ingress_EC2TCP" {
  security_group_id = aws_security_group.EC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "TCP"
  from_port         = "80"
  to_port           = "80"
}

resource "aws_vpc_security_group_ingress_rule" "EC2_ingress_EC2ICMP" {
  security_group_id = aws_security_group.EC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "ICMP"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_egress_rule" "EC2_egress" {
  security_group_id = aws_security_group.EC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "TCP"
  from_port         = 0
  to_port           = 65535

}
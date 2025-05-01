

resource "aws_instance" "ec2_ins" {

  instance_type = "t2.micro"
  #availability_zone      = var.availabilityzone[count.index]
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.EC2_SG.id]
  ami                         = "ami-002f6e91abff6eb96"
  associate_public_ip_address = true
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    curl http://169.254.169.254/latest/meta-data/instance-id
    EOF
}

/*

output "aws_instance_ip" {
  value = aws_instance.ec2_ins[count.index].public_dns

}

output "aws_instance_dns" {
  value = aws_instance.ec2_ins[count.index].public_ip

}

*/
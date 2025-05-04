/*


variable "db_username" {
  default = "mydatabase"

}

variable "db_password" {
  description = "Database password"
  sensitive   = true


}

resource "aws_db_instance" "postgress-db" {
  identifier        = "my-postgres-db"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = var.db_username
  password          = var.db_password



  multi_az                = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 0

  vpc_security_group_ids = [aws_security_group.db-postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres-subnetgp.name



  tags = {
    Name = "postgre-db"
    Env  = "dev"
  }
}


resource "aws_db_subnet_group" "postgres-subnetgp" {
  name       = "db-subnet-gp"
  subnet_ids = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

}



output "db-dnsendpoint" {
  value = aws_db_instance.postgress-db.endpoint

}

output "db-port" {
  value = aws_db_instance.postgress-db.port

}
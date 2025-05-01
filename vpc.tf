# create a vpc with cidr

resource "aws_vpc" "ranjitvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name        = "main-vpc"
    environment = "dev"
  }
}

# create public subnet 1

resource "aws_subnet" "public_subnet1" {

  vpc_id            = aws_vpc.ranjitvpc.id
  cidr_block        = var.public_cidr[0]
  availability_zone = var.availabilityzone[0]
  tags = {
    name = "dev-public-subnet1"
  }
}

# create public subnet 2
resource "aws_subnet" "public_subnet2" {

  vpc_id            = aws_vpc.ranjitvpc.id
  cidr_block        = var.public_cidr[1]
  availability_zone = var.availabilityzone[1]
  tags = {
    name = "dev-public-subnet2"
  }
}

# create private subnet

resource "aws_subnet" "private_subnet" {

  vpc_id            = aws_vpc.ranjitvpc.id
  cidr_block        = var.private_cidr[0]
  availability_zone = var.availabilityzone[0]
  tags = {
    name = "dev-private-subnet"
  }
}

# create an internet gateway for public subnet

resource "aws_internet_gateway" "intGW" {
  vpc_id = aws_vpc.ranjitvpc.id
  tags = {
    name = "inernet GW for Public subnet"
  }
}

/*
# Internet GW attachment with public subnet
resource "aws_internet_gateway_attachment" "nameintGW_attach" {
  vpc_id              = aws_vpc.ranjitvpc.id
  internet_gateway_id = aws_internet_gateway.intGW.id

}

*/

# create one elastic ip

resource "aws_eip" "elastic_ip_for_privateSB" {
  domain = "vpc"

}

# create a nat gateway plus subnet association 
resource "aws_nat_gateway" "natGW" {
  allocation_id = aws_eip.elastic_ip_for_privateSB.id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on    = [aws_subnet.public_subnet1]
}



# public route
resource "aws_route_table" "public-routeTB" {
  vpc_id = aws_vpc.ranjitvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.intGW.id
  }
  tags = {
    name = "internet to aws"
  }
}
# route table association with subnet

resource "aws_route_table_association" "publiocRTassoc1" {
  route_table_id = aws_route_table.public-routeTB.id
  subnet_id      = aws_subnet.public_subnet1.id
}

resource "aws_route_table_association" "publiocRTassoc2" {
  route_table_id = aws_route_table.public-routeTB.id
  subnet_id      = aws_subnet.public_subnet2.id
}

# private route table

resource "aws_route_table" "private-routeTB" {
  vpc_id = aws_vpc.ranjitvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natGW.id
  }
  tags = {
    name = "priavte-route"
  }
}

# private route association
resource "aws_route_table_association" "privateRTassoc" {
  route_table_id = aws_route_table.private-routeTB.id
  subnet_id      = aws_subnet.private_subnet.id
}



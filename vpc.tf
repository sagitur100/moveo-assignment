# Create the requested VPC, main route table is created as well.
resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "nginx-vpc"
 }
}

# Public subnets
resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
 
# Private subnets
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}


resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "Nginx VPC IG"
 }
}

## Import as data resource the default route table
## attached to private subnets
#data "aws_route_table" "default-rt" {
#  vpc_id = aws_vpc.main.id
#  subnet_id = aws_subnet.private_subnets[0].id
#
#}
resource "aws_route_table" "private_routing_table" {
  vpc_id = aws_vpc.main.id
}


# Create the second route table 
# (the main is created with the vpc)
# that will enable public access
resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.main.id
 
 route { 
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "2nd Route Table"
 }
}


# Associate public subnets with the second routing table that enable access to public internet.
resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}



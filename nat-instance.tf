# Define security group allowing inbound HTTP
resource "aws_security_group" "nat_instance_sg" {
  name        = "nat_instance_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  # Allow inbound HTTP traffic from servers in the private subnet
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    #cidr_blocks = [ var.private_subnet_cidrs[0] ]
  }
  
  # Allow inbound SSH access to the NAT instance from your network (over the internet gateway)
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define EC2 instance
resource "aws_instance" "nat_instance" {
  ami                    = "ami-01e82af4e524a0aa3"  # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [ aws_security_group.nat_instance_sg.id ]
  key_name               = aws_key_pair.tf_key_pair.key_name
  source_dest_check = false
  

  # Bootstrap script to configure NAT instance
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install iptables-services -y
              sudo systemctl enable iptables
              sudo systemctl start iptables
              sudo echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/custom-ip-forwarding.conf
              sudo sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf
              sudo /sbin/iptables -t nat -A POSTROUTING -o $(ip -br l | awk '$1 !~ "lo|vir|wl" { print $1}') -j MASQUERADE
              sudo /sbin/iptables -F FORWARD
              sudo service iptables save
              EOF

  tags = {
    Name = "nat-instance"
  }
}

resource "aws_route" "private_nat_instance_route" {
    route_table_id = aws_route_table.private_routing_table.id
    destination_cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
}

resource "aws_eip" "nat_instance_eip" {
  instance = aws_instance.nat_instance.id
  domain   = "vpc"
  depends_on = [ aws_internet_gateway.gw ]
}

resource "aws_route_table_association" "private_routing_table_assoc" {
  route_table_id = aws_route_table.private_routing_table.id
  subnet_id = aws_subnet.private_subnets[0].id
}

output "nat_instance_ip" {
  value = aws_eip.nat_instance_eip.public_ip
}
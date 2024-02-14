# Define security group allowing inbound HTTP
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id

  # Allow inbound Nginx default port
  ingress {
    from_port = 80
    to_port = 80
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

# Create key pair for nginx-docker-host
resource "aws_key_pair" "tf_key_pair" {
  key_name = "nginx-docker-host-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Generate the private key on the local system
resource "local_file" "tf_private_key" {
  content = tls_private_key.rsa.private_key_pem
  filename = "tf_private_key"
}


# Define EC2 instance
resource "aws_instance" "nginx-docker-host" {
  ami                    = "ami-01e82af4e524a0aa3"  # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnets[0].id
  vpc_security_group_ids = [ aws_security_group.instance_sg.id ]
  key_name               = aws_key_pair.tf_key_pair.key_name

  # Bootstrap script to install Docker
  user_data = <<-EOF
              #!/bin/bash
              sudo amazon-linux-extras install docker -y
              sudo systemctl enable docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              docker run -d -p 80:80 sagitur100/nginx
              EOF

  tags = {
    Name = "nginx-docker-host"
  }
}



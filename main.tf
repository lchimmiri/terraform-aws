provider "aws" {
  region = "us-east-1"
}

# module "ec2_instance" {
#   source = "./modules/ec2_instance"
#   ami_id = var.ami_id
#   instance_type = var.instance_type
#   subnet_id = var.subnet_id
# }

# module "s3_bucket" {
#   source = "./modules/s3_bucket"
#   s3_bucket_name = var.s3_bucket_name
# }

resource "aws_key_pair" "KP" {
  key_name = "terraform-demo-naidu"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sb1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "tra1" {
  subnet_id = aws_subnet.sb1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "webSg" {
  name = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "Web-sg"
  }
}

resource "aws_instance" "server" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.KP.key_name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id = aws_subnet.sb1.id

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }

  # File provisioner to copy a file from local to the remote ec2 instance
  provisioner "file" {
    source = "app.py"
    destination = "/home/ubuntu/app.py"
  }

  # run the python app
  provisioner "remote-exec" {
    inline = [
    "echo 'Hello from the remote instance' ",
      "sudo apt update -y",
      "sudo apt-get install -y python3-pip",
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &"
    ]
  }
}
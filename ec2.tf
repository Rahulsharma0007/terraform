#region

provider "aws"  { 
 
   region = "ap-south-1"
}

# keyvalue pair


resource  aws_key_pair  my_key_pair {
  key_name   = "terra-automate-key.pub"
  public_key = file("terra-automate-key.pub")
}

# default VPC
resource  aws_default_vpc  default {}

# security group

resource  aws_security_group  my_security_group {
  name        = "terra-security"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_default_vpc.default.id        #interpolation
  }

# inbound and outbound rule
resource aws_vpc_security_group_ingress_rule  allow_http {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = aws_default_vpc.default.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource aws_vpc_security_group_ingress_rule  allow_SSH {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource aws_vpc_security_group_egress_rule  allow_all_traffic {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# EC2 instance 

resource aws_instance my_instance {
    tags = {
    Name = "Terra-auto-server"
  }
   
   ami = "ami-05d2d839d4f73aafb"
   instance_type = "t3.micro"
   key_name = aws_key_pair.my_key_pair.key_name


   vpc_security_group_ids = [aws_security_group.my_security_group.id]

# root storage
 root_block_device {
   
   volume_size= 8
   volume_type= "gp3"

}


}

resource "aws_ec2_instance_state" "test" {
  count = 3
  instance_id = aws_instance.my_instance[count.index].id
  state       = "stopped"
}























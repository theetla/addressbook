resource "aws_security_group" "mywebsecurity" {
  name        = "ownsecurityrules"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id
 
   ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     }
 
  ingress {
    description      = "HTTP"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     }
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
 
  tags = {
    Name = "${var.env}-sg"
  }
}
data "aws_ami" "latest_ami"{
  most_recent = true
  filter{
    name ="name"
    values=["amzn2-ami-kernel-*-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
   owners = ["amazon"]
}
resource "aws_instance" "webserver" {
  ami           = data.aws_ami.latest_ami.id
  instance_type = var.instance_type
   associate_public_ip_address =true
   subnet_id=var.subnet_id
   vpc_security_group_ids = [aws_security_group.mywebsecurity.id]
   key_name="jenkinsmaster.pem"
   user_data = file("script.sh")   
  tags = {
    Name = "${var.env}-mywebserver"
  }
}
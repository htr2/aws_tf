resource "aws_instance" "vm1" {
  instance_type = "t2.micro"
  ami           = "ami-03ededff12e34e59e" #Amazon Linux 2 Kernel 5.10 AMI 2.0.20220406.1 x86_64 HVM gp2

  tags = {
    Name = "vm1"
  }

  key_name               = "hvoelksen-aws-mgmt"
  vpc_security_group_ids = [aws_security_group.public_security_group.id]
  subnet_id              = aws_subnet.us-east-1a-public_subnet.id
  user_data              = templatefile("userdata.sh", {})

  root_block_device {
    volume_size = 8
  }
}
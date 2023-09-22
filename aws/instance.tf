# resource "aws_key_pair" "key-tf" {
#   key_name   = "key-tf"
#   public_key = file("${path.module}/id_rsa.pub")
# }

# # output "keyname" {
# #     value = "${aws_key_pair.key-tf.key_name}"
# # }

# resource "aws_security_group" "allow_tls" {
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic"
#   dynamic "ingress" {
#     for_each = [22, 80, 443, 3306, 27017]
#     iterator = port
#     content {
#       description = "TLS from VPC"
#       from_port   = port.value
#       to_port     = port.value
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
# }


# resource "aws_instance" "create-ec2-vm" {
#   ami                    = "ami-024e6efaf93d85776"
#   instance_type          = "t2.micro"
#   key_name               = aws_key_pair.key-tf.key_name
#   vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
#   tags = {
#     Name = "first-tf-instance"
#   }
# }
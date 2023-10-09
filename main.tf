resource "aws_security_group" "rabbitmq_sg" {
  name        = "${var.component}-${var.env}-SG"
  description = "Allow ${var.component}-${var.env}-Traffic"
  vpc_id = var.vpc_id

  ingress {
    description      = "Allow inbound traffic for ${var.component}-${var.env}"
    from_port        = 5672
    to_port          = 5672
    protocol         = "tcp"
    cidr_blocks      = var.sg_subnet_cidr
  }

  ingress {
    description      = "Allow ssh traffic for bastion_host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.bastion_host
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.env}-${var.component}-SG"
  },
    var.tags)
}


resource "aws_instance" "rabbitmq-instance" {
  instance_type = var.instance_type
  ami = data.aws_ami.ami.id
  vpc_security_group_ids = [aws_security_group.rabbitmq_sg.id]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  subnet_id = var.subnet_id

  user_data     = templatefile("${path.module}/userdata.sh", {
    env = var.env
    component = var.component

  })

  tags = merge({
    Name = "${var.env}-${var.component}"
  },
    var.tags)
}

resource "aws_route53_record" "rabbitmq_record" {
  zone_id = var.zone_id
  name    = "${var.component}-${var.env}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.rabbitmq-instance.private_ip]
}
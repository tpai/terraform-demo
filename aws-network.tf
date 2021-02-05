resource "aws_vpc" "odhk_data_vpc" {
  cidr_block = "172.30.0.0/16"
  tags = {
    Name = "odhk_data_vpc"
  }
}

resource "aws_subnet" "odhk_data_public_subset_1" {
  vpc_id     = aws_vpc.odhk_data_vpc.id
  cidr_block = "172.30.1.0/24"
  tags = {
    Name = "odhk_data_public_subset_1"
  }
}

resource "aws_subnet" "odhk_data_public_subset_2" {
  vpc_id     = aws_vpc.odhk_data_vpc.id
  cidr_block = "172.30.2.0/24"
  tags = {
    Name = "odhk_data_public_subset_2"
  }
}

resource "aws_subnet" "odhk_data_public_subset_5" {
  vpc_id     = aws_vpc.odhk_data_vpc.id
  cidr_block = "172.30.5.0/24"
  tags = {
    Name = "odhk_data_public_subset_5"
  }
}

resource "aws_subnet" "odhk_data_public_subset_6" {
  vpc_id     = aws_vpc.odhk_data_vpc.id
  cidr_block = "172.30.6.0/24"
  tags = {
    Name = "odhk_data_public_subset_6"
  }
}

resource "aws_subnet" "odhk_data_public_subset_7" {
  vpc_id     = aws_vpc.odhk_data_vpc.id
  cidr_block = "172.30.7.0/24"
  tags = {
    Name = "odhk_data_public_subset_7"
  }
}

resource "aws_subnet" "odhk_data_public_subset_8" {
  vpc_id     = aws_vpc.odhk_data_vpc.id
  cidr_block = "172.30.8.0/24"
  tags = {
    Name = "odhk_data_public_subset_8"
  }
}

resource "aws_security_group_rule" "odhk_data_pipeline_eks_sg_in_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.odhk_data_pipeline_eks_sg.id
}

resource "aws_security_group_rule" "odhk_data_pipeline_eks_sg_in_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.odhk_data_pipeline_eks_sg.id
}

resource "aws_security_group_rule" "odhk_data_pipeline_eks_sg_out_3306" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.odhk_data_pipeline_eks_sg.id
}

resource "aws_security_group_rule" "odhk_data_pipeline_redis_sg_in_6379" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.odhk_data_pipeline_redis_sg.id
}

resource "aws_security_group_rule" "odhk_data_pg_sg_in_3306" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.odhk_data_pg_sg.id
}

resource "aws_security_group" "odhk_data_pipeline_eks_sg" {
  name   = "odhk_data_pipeline_eks_sg"
  vpc_id = aws_vpc.odhk_data_vpc.id
}

resource "aws_security_group" "odhk_data_pg_sg" {
  name   = "odhk_data_pg_sg"
  vpc_id = aws_vpc.odhk_data_vpc.id
}

resource "aws_security_group" "odhk_data_pipeline_redis_sg" {
  name   = "odhk_data_pipeline_redis_sg"
  vpc_id = aws_vpc.odhk_data_vpc.id
}

resource "aws_elasticache_security_group" "odhk_data_pipeline_redis_sg" {
  name                 = "odhk_data_pipeline_redis_sg"
  security_group_names = [aws_security_group.odhk_data_pipeline_redis_sg.name]
}

resource "aws_elb" "odhk_data_pipeline_elb" {
  name      = "odhk-data-pipeline-elb"
  subnets   = [aws_subnet.odhk_data_public_subset_6.id, aws_subnet.odhk_data_public_subset_7.id, aws_subnet.odhk_data_public_subset_8.id]
  internal  = false

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
}

resource "aws_subnet" "odhk_data_gateway_subnet" {
  vpc_id     = aws_vpc.odhk_data_vpc.id
  cidr_block = "172.30.0.0/24"
  tags = {
    Name = "odhk_data_gateway_subnet"
  }
}

resource "aws_nat_gateway" "odhk_data_natgw" {
  allocation_id = aws_eip.odhk_data_eip.id
  subnet_id     = aws_subnet.odhk_data_gateway_subnet.id
}

resource "aws_route_table" "odhk_data_nat_rt" {
  vpc_id = aws_vpc.odhk_data_vpc.id

  route {
    cidr_block = "172.30.0.0/24"
    gateway_id = aws_nat_gateway.odhk_data_natgw.id
  }
}

resource "aws_network_interface" "odhk_data_ni" {
  subnet_id   = aws_subnet.odhk_data_gateway_subnet.id
  private_ips = ["172.30.0.1"]
}

resource "aws_eip" "odhk_data_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.odhk_data_ni.id
  associate_with_private_ip = "172.30.0.1"
}

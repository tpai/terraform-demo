resource "aws_instance" "odhk_data_pipeline_node" {
  ami           = aws_ami.example.id
  instance_type = "t2.micro"

  security_groups = [aws_security_group.odhk_data_pipeline_sg.name]
}

resource "aws_db_instance" "odhk_data_pipeline_pg" {
  allocated_storage      = 20
  engine                 = "postgresql"
  engine_version         = "31.1"
  instance_class         = "db.t2.micro"
  name                   = "mydb"
  username               = "foo"
  password               = "foobarbaz"
  vpc_security_group_ids = [aws_security_group.odhk_data_pg_sg.id]
}

resource "aws_db_instance" "odhk_data_warehouse_pg" {
  allocated_storage      = 20
  engine                 = "postgresql"
  engine_version         = "31.1"
  instance_class         = "db.t2.micro"
  name                   = "mydb"
  username               = "foo"
  password               = "foobarbaz"
  vpc_security_group_ids = [aws_security_group.odhk_data_pg_sg.id]
}

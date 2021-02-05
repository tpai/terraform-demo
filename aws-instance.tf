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

resource "aws_elasticache_cluster" "odhk_data_pipeline_redis_ec" {
  cluster_id           = "odhk-data-pipeline-redis-ec"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  security_group_ids = [aws_elasticache_security_group.odhk_data_pipeline_redis_sg.id]
}

resource "aws_db_instance" "banco_zabbix" {
  allocated_storage      = 20
  max_allocated_storage  = 40
  engine                 = "mariadb"
  engine_version         = "10.6.14"
  instance_class         = "db.t3.micro"
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.subnet_db.name
  vpc_security_group_ids = [aws_security_group.bd_sg.id]
  skip_final_snapshot    = true
  username               = var.zabbix.services.db_user
  password               = var.zabbix.services.db_pass
}
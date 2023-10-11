data "template_file" "install_zabbix_server" {
  template = file("install_zabbix_server.sh.tpl")

  vars = {
    ZABBIX_DB_USER   = var.zabbix.services.db_user
    ZABBIX_DB_PASS   = var.zabbix.services.db_pass
    ZABBIX_DB_SERVER = aws_db_instance.banco_zabbix.address
    ZABBIX_DB_NAME   = var.zabbix.services.db_name
  }
}

data "template_file" "install_glpi" {
  template = file("install_glpi.sh.tpl")

  vars = {
    GLPI_DB_USER   = var.glpi.services.db_user
    GLPI_DB_PASS   = var.glpi.services.db_pass
    GLPI_DB_SERVER = var.glpi.services.db_server
    GLPI_DB_NAME   = var.glpi.services.db_name
  }
}

data "template_file" "install_grafana" {
  template = file("install_grafana.sh.tpl")
}

resource "aws_key_pair" "key" {
  key_name   = "aws-key"
  public_key = file("./id_rsa.pub")
}

resource "aws_instance" "zabbix_server" {
  ami                         = "ami-007855ac798b5175e"
  instance_type               = var.servers.type.zabbix
  subnet_id                   = aws_subnet.public_subnet.id
  security_groups             = [aws_security_group.sg_padrao.id]
  key_name                    = aws_key_pair.key.key_name
  associate_public_ip_address = true
  user_data                   = data.template_file.install_zabbix_server.rendered

  depends_on = [aws_security_group.sg_padrao, aws_db_instance.banco_zabbix]

  tags = {
    Name = "Zabbix_Server"
  }
}

resource "aws_instance" "grafana" {
  ami                         = "ami-007855ac798b5175e"
  instance_type               = var.servers.type.grafana
  subnet_id                   = aws_subnet.public_subnet.id
  security_groups             = [aws_security_group.sg_padrao.id]
  key_name                    = aws_key_pair.key.key_name
  associate_public_ip_address = true
  user_data                   = data.template_file.install_grafana.rendered

  depends_on = [aws_security_group.sg_padrao]

  tags = {
    Name = "Grafana"
  }
}

resource "aws_instance" "glpi" {
  ami                         = "ami-007855ac798b5175e"
  instance_type               = var.servers.type.glpi
  subnet_id                   = aws_subnet.public_subnet.id
  security_groups             = [aws_security_group.sg_padrao.id]
  key_name                    = aws_key_pair.key.key_name
  associate_public_ip_address = true
  user_data                   = data.template_file.install_glpi.rendered

  depends_on = [aws_security_group.sg_padrao]

  tags = {
    Name = "GLPI"
  }
}
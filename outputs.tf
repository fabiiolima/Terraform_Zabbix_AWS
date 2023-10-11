output "vm_ip_publico_Zabbix" {
  value = aws_instance.zabbix_server.public_ip
}

output "vm_ip_privado_Zabbix" {
  value = aws_instance.zabbix_server.private_ip
}

output "vm_ip_privado_GLPI" {
  value = aws_instance.glpi.private_ip
}

output "vm_ip_privado_Grafana" {
  value = aws_instance.grafana.private_ip
}

output "Endpoint_Banco" {
  value = aws_db_instance.banco_zabbix.address
}

output "Subnet_ID" {
  value = aws_subnet.private_subnet_a.id
}

output "Security_Groups_ID" {
  value = aws_security_group.sg_padrao.id
}

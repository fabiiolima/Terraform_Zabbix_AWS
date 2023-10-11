variable "region" {
  description = "Região aonde será provisionada os recursos"
  type        = string
  default     = "us-east-1"
}

variable "zabbix" {
  description = "Variaveis Serviço Zabbix"
  type        = map(any)
  default = {
    "services" = {
      db_name = "zabbix"
      db_user = "zabbix"
      db_pass = "zabbixzabbix"
    }
  }
}

variable "glpi" {
  description = "Variáveis Serviço GLPI"
  type        = map(any)
  default = {
    "services" = {
      db_name   = "glpi"
      db_user   = "glpi"
      db_pass   = "glpi"
      db_server = "localhost"
    }
  }
}

variable "servers" {
  description = "Tipo de máquinas"
  type        = map(any)
  default = {
    "type" = {
      zabbix  = "t2.micro"
      glpi    = "t2.micro"
      grafana = "t2.micro"
    }
  }
}

variable "ebs_volume" {
  description = "Volume do EBS em Gb"
  type        = number
  default     = 20
}

variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    project_name = "expense"
    environment  = "dev"
    terraform    = "true"
  }
}

variable "pass" {
  default = "ExpenseApp1"
}

variable "zone_id"{
    default = "Z08883041FCAUWQH3PBF3"
}

variable "domain_name" {
  default = "rushhav.fun"
}
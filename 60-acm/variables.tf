variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "domain_name" {
    default = "rushhav.fun"
}

variable "zone_id" {
    default = "Z08883041FCAUWQH3PBF3"
}
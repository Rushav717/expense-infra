module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.resource_name

  engine            = "mysql"
  engine_version    = "8.0.43"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name     = "transactions"
  username    = "root"
  port        = "3306"
  password_wo = "ExpensesApp1"
  password_wo_version = 2
  # manage_master_user_password = false

  vpc_security_group_ids = [local.mysql_sg_id]
  skip_final_snapshot = true

  tags = merge(
    var.common_tags,
    {
      Owner       = "user"
      Environment = "dev"
      name        = local.resource_name
    }
  )

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name   = local.db_subnet_group_name

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]

}

resource "aws_route53_record" "C_NAME" {
  zone_id = var.zone_id
  name    = "mysql-${var.environment}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 1
  records = [module.db.db_instance_address]
}
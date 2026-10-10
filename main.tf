resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.linux.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.wordpress.id]
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf update -y
    dnf install -y httpd php php-fpm php-mysqli mariadb105 wget tar
    systemctl enable --now php-fpm httpd
    cd /var/www/html
    wget -q https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
    cat > wp-config.php <<'WP'
    <?php
    define('DB_NAME', '${var.db_name}');
    define('DB_USER', '${var.db_username}');
    define('DB_PASSWORD', '${var.db_password}');
    define('DB_HOST', '${aws_db_instance.mysql.address}');
    $table_prefix = 'wp_';
    require_once __DIR__ . '/wp-settings.php';
    WP
    chown -R apache:apache /var/www/html
  EOF

  tags = {
    Name = "wordpress"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "wordpress-db"
  engine                 = "mysql"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.private.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  skip_final_snapshot    = true # workshop only
}

data "aws_vpc" "default" { default = true }

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# The default VPC only has public subnets. The database stays unreachable from
# the internet because publicly_accessible = false and its security group only
# accepts traffic from the WordPress server.
resource "aws_db_subnet_group" "private" {
  name       = "wordpress-db"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_security_group" "wordpress" {
  name   = "wordpress"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Lets the server download packages and WordPress.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name   = "wordpress-db"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress.id]
  }
}

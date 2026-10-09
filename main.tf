resource "aws_instance" "wordpress" {
  ami                    = data.aws_ami.linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.wordpress.id]

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf update -y
    dnf install -y httpd php php-mysqli mariadb105 wget tar
    systemctl enable --now httpd
    cd /var/www/html
    wget -q https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    cat > wp-config.php <<'WP'
    <?php
    define('DB_NAME', '${var.db_name}');
    define('DB_USER', '${var.db_username}');
    define('DB_PASSWORD', '${var.db_password}');
    define('DB_HOST', '${aws_db_instance.mysql.address}');
    require_once __DIR__ . '/wp-settings.php';
    WP
    chown -R apache:apache /var/www/html
  EOF
}

resource "aws_db_instance" "mysql" {
  engine                 = "mysql"
  db_subnet_group_name   = aws_db_subnet_group.private.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  skip_final_snapshot    = true # workshop only
}

data "aws_vpc" "default" { default = true }
data "aws_ami" "linux" { most_recent = true }

resource "aws_security_group" "wordpress" {
  ingress {
    from_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}